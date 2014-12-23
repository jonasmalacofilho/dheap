hx=haxe
flags=-cp lib -cp tests -lib utest -main DHeapTests $(HXFLAGS)

all: neko java cpp PHONY

neko: out/neko/DHeapTests.n PHONY
	neko out/neko/DHeapTests.n

java: out/java/DHeapTests.jar PHONY
	java -jar out/java/DHeapTests.jar

cpp: out/cpp/DHeapTests PHONY
	out/cpp/DHeapTests

clean: PHONY
	rm -rf out

out/neko/DHeapTests.n: PHONY
	$(hx) $(flags) -neko $@

out/java/DHeapTests.jar: PHONY
	$(hx) $(flags) -java `dirname $@`

out/cpp/DHeapTests: PHONY
	$(hx) $(flags) -cpp `dirname $@`

.PHONY: PHONY

