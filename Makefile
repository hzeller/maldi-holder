all : maldi-holder.stl

%.stl: %.scad
	openscad -o $@ -d $@.deps $<

clean:
	rm -f maldi-holder.stl
