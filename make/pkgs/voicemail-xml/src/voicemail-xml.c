#include <ctype.h>
#include <expat.h>
#include <stdio.h>
#include <string.h>

enum { ID, TYPE, PORT, CALLER, CALLER_NUMBER, CALLED, DATE, DEVICE, PATH, TITLE, URL, IDX, TAM, NUM, TAMURL, FIELDS };
static const char *const fields[] = {
    "Id", "Type", "Port", "Caller", "CallerNumber", "CalledNumber", "Date",
    "Device", "Path", "Name", "NewCallListURL", "Index", "Tam", "Number", "NewURL"
};

struct parse {
    XML_Parser parser;
    unsigned depth, call, seen;
    int field, mode, invalid;
    size_t used;
    char values[FIELDS][1024];
};

static const char *element(const char *name)
{
    const char *separator = strrchr(name, '|');
    return separator ? separator + 1 : name;
}

static void start(void *data, const char *name, const char **attributes)
{
    struct parse *p = data;
    unsigned i;
    (void)attributes;
    name = element(name);
    ++p->depth;
    if (p->mode % 2 == 0 && p->depth == 1 && strcmp(name, "root") != 0 &&
        strcmp(name, "Root") != 0) {
        XML_StopParser(p->parser, XML_FALSE);
        return;
    }

    if (p->mode % 2 == 0 && p->depth == 2 && strcmp(name, p->mode == 2 ? "Message" : "Call") == 0) {
        p->call = p->depth;
        p->seen = 0;
        p->invalid = 0;
        memset(p->values, 0, sizeof p->values);
        return;
    }
    if (p->field >= 0) {
        XML_StopParser(p->parser, XML_FALSE);
        return;
    }
    if (p->mode % 2 == 0 && (!p->call || p->depth != p->call + 1))
        return;

    for (i = 0; i < FIELDS; ++i) {
        if (((p->mode == 0 || p->mode == 4) && i >= URL) ||
            (p->mode == 1 && i != URL) ||
            (p->mode == 2 && i != IDX && i != TAM && i != PATH && i != NUM && i != DATE) ||
            (p->mode == 3 && i != TAMURL))
            continue;
        if (strcmp(name, fields[i]) != 0)
            continue;
        if (p->seen & (1U << i))
            p->invalid = 1;
        p->seen |= 1U << i;
        p->field = i;
        p->used = 0;
        break;
    }
}

static void text(void *data, const char *value, int length)
{
    struct parse *p = data;
    if (p->field < 0)
        return;
    if ((size_t)length >= sizeof p->values[0] - p->used) {
        XML_StopParser(p->parser, XML_FALSE);
        return;
    }
    memcpy(p->values[p->field] + p->used, value, length);
    p->used += length;
    p->values[p->field][p->used] = '\0';
}

static int tam_port(const char *port)
{
    return strcmp(port, "6") == 0 ||
        (strlen(port) == 2 && port[0] == '4' && isdigit((unsigned char)port[1]));
}

static void print_call(struct parse *p)
{
    char (*v)[1024] = p->values;
    const unsigned output[] = { ID, PORT, CALLER, CALLED, DATE, DEVICE, PATH, TITLE };
    unsigned i;

    if (p->mode == 2) {
        if (!p->invalid && v[IDX][0] && v[TAM][0] && v[PATH][0] && v[DATE][0] &&
            strspn(v[IDX], "0123456789") == strlen(v[IDX]) &&
            strspn(v[TAM], "0123456789") == strlen(v[TAM]) &&
            !strpbrk(v[PATH], "|\r\n\t") && !strpbrk(v[NUM], "|\r\n\t") &&
            !strpbrk(v[DATE], "|\r\n\t"))
            printf("%s|%s|%s|%s|%s\n", v[IDX], v[TAM], v[NUM], v[DATE], v[PATH]);
        return;
    }

    if (p->invalid || v[ID][0] == '\0' || strspn(v[ID], "0123456789") != strlen(v[ID]) ||
        strcmp(v[TYPE], p->mode == 4 ? "9" : "1") != 0 || !tam_port(v[PORT]) || !v[DATE][0])
        return;
    if (v[CALLER_NUMBER][0])
        memcpy(v[CALLER], v[CALLER_NUMBER], sizeof v[CALLER]);
    for (i = 0; i < sizeof output / sizeof output[0]; ++i) {
        if (strpbrk(v[output[i]], "|\r\n\t"))
            return;
    }
    for (i = 0; i < sizeof output / sizeof output[0]; ++i)
        printf("%s%s", i ? "|" : "", v[output[i]]);
    putchar('\n');
}

static void end(void *data, const char *name)
{
    struct parse *p = data;
    name = element(name);
    if (p->field >= 0 && strcmp(name, fields[p->field]) == 0)
        p->field = -1;
    if (p->call && p->depth == p->call) {
        print_call(p);
        p->call = 0;
    }
    --p->depth;
}

int main(int argc, char **argv)
{
    struct parse p = { .field = -1 };
    char chunk[4096];
    size_t count;
    int done, status = 1;

    if (argc != 2)
        return 2;
    if (strcmp(argv[1], "calls") == 0) p.mode = 0;
    else if (strcmp(argv[1], "url") == 0) p.mode = 1;
    else if (strcmp(argv[1], "messages") == 0) p.mode = 2;
    else if (strcmp(argv[1], "tam-url") == 0) p.mode = 3;
    else if (strcmp(argv[1], "active-calls") == 0) p.mode = 4;
    else return 2;
    p.parser = XML_ParserCreateNS(NULL, '|');
    if (!p.parser)
        return 1;
    XML_SetUserData(p.parser, &p);
    XML_SetElementHandler(p.parser, start, end);
    XML_SetCharacterDataHandler(p.parser, text);

    do {
        count = fread(chunk, 1, sizeof chunk, stdin);
        if (ferror(stdin))
            goto out;
        done = feof(stdin);
        if (XML_Parse(p.parser, chunk, count, done) != XML_STATUS_OK)
            goto out;
    } while (!done);
    if (p.mode % 2 != 0) {
        const char *url = p.values[p.mode == 1 ? URL : TAMURL];
        if (p.invalid || !url[0] || strpbrk(url, "\r\n\t"))
            goto out;
        puts(url);
    }
    status = ferror(stdout) ? 1 : 0;
out:
    XML_ParserFree(p.parser);
    return status;
}
