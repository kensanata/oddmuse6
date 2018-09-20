jobs ?= 4

test:
	prove6 -l -j=$(jobs) t

clean:
	rm -rf test-*

# Verbose:
# prove6 -l -v t/edit.t
# Set all the environment variables:
# dir=. storage=Storage::File menu="Home, Changes, About" changes="Changes" prove6 -l t
