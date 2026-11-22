ZIG ?= zig
ZIGFLAGS ?= -O small
LDLIBS := $(shell pkg-config --libs libnotify)

TARGET := bin/upgrNotif
SOURCE := src/main.zig

$(TARGET): $(SOURCE) | bin
	$(ZIG) build-exe $(SOURCE) $(ZIGFLAGS) -femit-bin=$(TARGET) $(LDLIBS) -lc


bin:
	mkdir -p bin

.PHONY: clean
clean:
	rm -f $(TARGET)
