TARGET = voicemail-xml
LDLIBS += -lexpat

all: $(TARGET)

$(TARGET): $(TARGET).o
	$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

clean:
	$(RM) $(TARGET) $(TARGET).o

.PHONY: all clean
