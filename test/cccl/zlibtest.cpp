#include <iostream>

extern "C" {
void deflate();
}

void main(int argc, void **argv)
{
	std::cout << "Hello world" << std::endl;
	
	deflate();
}
