import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_river_pod/hooks_river_pod.dart';

void main() {
  testWidgets('provider1 as override of normal provider', (tester) async {
    final provider = Provider((_) => 42);
    final provider2 = Provider((_) => 42);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          provider2.overrideForSubtree(
            Provider<int>((state) {
              final other = state.dependOn(provider);
              return other.value * 2;
            }),
          ),
        ],
        child: HookBuilder(builder: (c) {
          return Text(useProvider(provider2).toString(), textDirection: TextDirection.ltr);
        }),
      ),
    );

    expect(find.text('84'), findsOneWidget);
  });

  testWidgets('provider1 can read and listen to other providers',
      (tester) async {
    // ProviderContext<int> providerState;

    // final provider = Provider<int>((state) {
    //   providerState = state;
    //   return 42;
    // });
    // var createCount = 0;
    // final provider1 =
    //     Provider1<ProviderSubscription<int>, String>(useProvider, (state, first) {
    //   createCount++;
    //   first.onChange((v) {
    //     state.value = v.toString();
    //   });
    //   return first.value.toString();
    // });

    // await tester.pumpWidget(
    //   ProviderScope(
    //     child: HookBuilder(builder: (c) {
    //       return Text(useProvider1(), textDirection: TextDirection.ltr);
    //     }),
    //   ),
    // );

    // expect(find.text('42'), findsOneWidget);

    // providerState.value = 21;
    // await tester.pump();

    // expect(createCount, 1);
    // expect(find.text('21'), findsOneWidget);
  }, skip: true);

  testWidgets('provider1 uses override if the override is at root',
      (tester) async {
    final provider = Provider((_) => 0);

    final provider1 = Provider((state) {
      final other = state.dependOn(provider);
      return other.value.toString();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          provider.overrideForSubtree(Provider((_) => 1)),
        ],
        child: HookBuilder(builder: (c) {
          return Text(useProvider(provider1), textDirection: TextDirection.ltr);
        }),
      ),
    );

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
  testWidgets('provider1 chain', (tester) async {
    final first = Provider((_) => 1);
    final second = Provider<int>((state) {
      final other = state.dependOn(first);
      return other.value + 1;
    });
    final third = Provider<int>((state) {
      final other = state.dependOn(second);
      return other.value + 1;
    });
    final forth = Provider<int>((state) {
      final other = state.dependOn(third);
      return other.value + 1;
    });

    await tester.pumpWidget(
      ProviderScope(
        child: HookBuilder(builder: (c) {
          return Text(useProvider(forth).toString(), textDirection: TextDirection.ltr);
        }),
      ),
    );

    expect(find.text('4'), findsOneWidget);
  });
  testWidgets('overriden provider1 chain', (tester) async {
    final first = Provider((_) => 1);
    final second = Provider<int>((state) {
      final other = state.dependOn(first);
      return other.value + 1;
    });
    final third = Provider<int>((state) {
      final other = state.dependOn(second);
      return other.value + 1;
    });
    final forth = Provider<int>((state) {
      final other = state.dependOn(third);
      return other.value + 1;
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          first.overrideForSubtree(Provider((_) => 42)),
        ],
        child: HookBuilder(builder: (c) {
          return Text(useProvider(forth).toString(), textDirection: TextDirection.ltr);
        }),
      ),
    );

    expect(find.text('45'), findsOneWidget);
  });
  testWidgets('partial override provider1 chain', (tester) async {
    final first = Provider((_) => 1);
    final second = Provider<int>((state) {
      final other = state.dependOn(first);
      return other.value + 1;
    });
    final third = Provider<int>((state) {
      final other = state.dependOn(second);
      return other.value + 1;
    });
    final forth = Provider<int>((state) {
      final other = state.dependOn(third);
      return other.value + 1;
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          second.overrideForSubtree(Provider((_) => 0)),
        ],
        child: HookBuilder(builder: (c) {
          return Text(useProvider(forth).toString(), textDirection: TextDirection.ltr);
        }),
      ),
    );

    expect(find.text('2'), findsOneWidget);
  });
  // TODO state hydratation
}