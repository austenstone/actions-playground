import sys


def main():
    who_to_greet = "World"
    if len(sys.argv) > 1:
        who_to_greet = sys.argv[1]
    print(f"Hello {who_to_greet}!")

if __name__ == "__main__":
    main()