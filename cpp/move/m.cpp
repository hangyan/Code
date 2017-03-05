#include <string>

using std::string;

void foo(string val) {

}

int main() {
    string val("Hello");
    foo(std::move(val));
    // warning: accessing val here is NOT fine!
    // original val is also destroyed here, but contains no value so it's fine
}
