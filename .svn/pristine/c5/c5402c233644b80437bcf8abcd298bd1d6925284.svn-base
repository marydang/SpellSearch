export LUA_PATH="`pwd`/test/?.lua;`pwd`/?.lua"
for TEST in $(find . -name "test_*" | grep -v luaunit | grep -v svn)
do
    lua $TEST;
done
