// not work use cat run.d and copy and paste the export line inbetween the double quotes
import std.process;

void main() {
    executeShell("export DYLD_LIBRARY_PATH=libs");
    executeShell("./guy");
}
