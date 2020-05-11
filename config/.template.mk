# Including of non standard library files:
#   INCLUDEDIR is where the header files can be found
#   LIBDIR is where the library object files can be found
INCLUDEDIR=/usr/include/
LIBDIR=/usr/lib

# If you have more source files add them here 
SOURCE= $(wildcard *.cpp)
DEPOBJ = $(patsubst %.cpp, %.d, $(SOURCE))

# The compiler we are using 
CC= g++

# The flags that will be used to compile the object file.
# If you want to debug your program,
# you can add '-g' on the following line
CFLAGS= -O2 -std=c++11 -g -Wall -pedantic -ggdb3 

# The name of the final executable 
EXECUTABLE=testprg

# The basic library we are using add the other libraries you want to link
# to your program here 

# Linux (default)
LDFLAGS = 

# If you have other library files in a different directory add them here 
INCLUDEFLAG= -I. -I$(INCLUDEDIR)
LIBFLAG= -L$(LIBDIR)

# Don't touch this one if you don't know what you're doing 
OBJECT= $(SOURCE:.cpp=.o)
DEPOBJECT= $(OBJECT:.o=.d)

# Don't touch any of these either if you don't know what you're doing 

all: $(EXECUTABLE)


$(EXECUTABLE): $(OBJECT) $(DEPOBJ)
	$(CC) $(CFLAGS) $(INCLUDEFLAG) $(LIBFLAG) $(OBJECT) -o $(EXECUTABLE) $(LDFLAGS) 


%.d: %.cpp
	$(CC) $(CFLAGS) $(INCLUDEFLAG) -MM $< > $@ 

%.o: %.cpp
	$(CC) $(CFLAGS) $(INCLUDEFLAG) -c $< -o $@

clean_object:
	rm -f $(OBJECT)

clean:
	rm -f $(OBJECT) $(DEPOBJ) $(EXECUTABLE)

-include $(DEPOBJ)
