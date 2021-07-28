# NOP language development.

This directory is for developing a Bison parser to refine and test the syntax of the NOP programming language. It's based on an ANSI C grammar that was taken from the web.  See the ./original directory for the original grammar, scanner, and FAQ that was downloaded.

## Status
The tag v0.0.1 has the correct grammer and the testing to show that. 
### The next steps
* Add a symbol table that can tell the difference between a user defined type and a normal indetifier. 
* Generalize the symbol table such that all type information is retained.
* Store constant values for retrieval.
* Create the data structures for the AST structure.
* Add the "visitor" functions to the AST.
* Add the "executor" functions to the AST to implement an AST-walk interpreter.
* Fork the implementation to use a FOSS virtual machine.
* Fork the implementation to use LLVM compiler backend.

### Other tasks
* Create documentation.
* External library interface.
* Import infrastrucutre.
