## prerequisiites
- cxxtest
- boost
- C++17
- cmake 3
- libasan (for debug builds to run with address sanitizer)
- ctags

## build
from the `c++` directory:
```
mkdir -p Debug && cd Debug && cmake -DCMAKE_BUILD_TYPE=Debug .. && make
mkdir -p Release && cd Release && cmake -DCMAKE_BUILD_TYPE=Release .. && make
```

## run
from inside `Relese` or `Debug` directories:
```
./dynamic_labor_run -h
Usage: ./dynamic_labor_run [OPTIONS]
	-v, --verbose		Print moment matrixes and other output. Should be used when running manually (default to FALSE)
	-s, --static		Run static mode, do not caluclate emax. (default to FALSE)
	-d, --data-dir=DATA_DIR	Location of input files. (default to ../../)
	-h, --help		Print this message

```
