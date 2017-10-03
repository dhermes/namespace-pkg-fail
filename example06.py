import pkg1_ns
import pkg1_ns.foo
try:
    from pkg1_ns import pkg4_ns
    from pkg1_ns.pkg4_ns import quux
except ImportError as exc:
    pkg4_ns = exc
    quux = None


def main():
    print('pkg1_ns: {!r}'.format(pkg1_ns))
    print('pkg1_ns.foo: {!r}'.format(pkg1_ns.foo))
    print('pkg1_ns.foo.BIG_NUM: {!r}'.format(pkg1_ns.foo.BIG_NUM))
    print('pkg1_ns.pkg4_ns: {!r}'.format(pkg4_ns))
    if quux is None:
        print('pkg1_ns.pkg4_ns.quux: N/A')
        print('pkg1_ns.pkg4_ns.quux.CHEESE: N/A')
    else:
        print('pkg1_ns.pkg4_ns.quux: {!r}'.format(quux))
        print('pkg1_ns.pkg4_ns.quux.CHEESE: {!r}'.format(quux.CHEESE))


if __name__ == '__main__':
    main()
