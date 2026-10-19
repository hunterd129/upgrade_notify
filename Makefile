CXX := clang++
CXXFLAGS := -std=c++17 -O3
CPPFLAGS := $(shell pkg-config --cflags libnotify)
LDLIBS := $(shell pkg-config --libs libnotify)

TARGET := bin/upgrNotif
SOURCE := src/main.cpp

$(TARGET): $(SOURCE)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(SOURCE) -o $(TARGET) $(LDLIBS)

.PHONY: clean
clean:
	rm -f $(TARGET)
