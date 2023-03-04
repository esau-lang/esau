# !/usr/bin/bash

# ldc2 -O --Oz --O5 src/land.d \
# ldc2 -release --DRT-gcopt=profile:2 -vgc src/land.d \
# ldc2 -release -O --Oz --O5 --DRT-gcopt=profile:2 src/land.d
# ldc2 -release -O --Oz --O5 --DRT-gcopt=profile:2\
# ldc2\
# ldc2 -release -O --Oz --O5 --DRT-gcopt=profile:2 -vgc\
ldc2\
	src/esau.d\
	\
	\
	src/ast/node.d\
	src/ast/exec.d\
	src/ast/lexer.d\
	src/ast/inter.d\
	src/ast/parser.d\
	src/ast/bytecode.d\
	src/ast/bytecode2.d\
	\
	\
	src/objects/function.d\
	src/objects/object.d\
	src/objects/type.d\
	\
	\
	src/modules/importlib.d\
	src/modules/base64.d\
	src/modules/bytes.d\
	src/modules/console.d\
	src/modules/dict.d\
	src/modules/dtypes.d\
	src/modules/file.d\
	src/modules/flare.d\
	src/modules/_json.d\
	src/modules/list.d\
	src/modules/math.d\
	src/modules/path.d\
	src/modules/random.d\
	src/modules/socket.d\
	src/modules/string.d\
	src/modules/sys.d\
	src/modules/time.d\
	\

rm esau.o
# ./esau main.eu