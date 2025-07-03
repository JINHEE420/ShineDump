import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../../core/core_features/local_storage/local_storage_manager.dart';
import '../../../../core/presentation/screens/full_screen_scaffold.dart';
import '../../../../core/presentation/styles/styles.dart';
import '../../../../core/presentation/utils/riverpod_framework.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/my_assets.dart';
import '../../../../utils/style.dart';
import '../sign_in_screen/sign_in_screen.dart';

enum TermType { personal, service, location }

extension TermTypeExt on TermType {
  String get text => switch (this) {
        TermType.personal => '개인 정보 활용 동의',
        TermType.service => '서비스 이용약관 동의',
        TermType.location => '위치기반서비스 동의',
      };

  String get pathFile => switch (this) {
        TermType.personal => Assets.term.termPersonal,
        TermType.service => Assets.term.termService,
        TermType.location => Assets.term.termLocation,
      };
}

/// A screen that displays and manages user agreements to various policy terms.
///
/// This widget handles the process of obtaining user consent for required
/// terms and conditions before allowing access to the application.
///
/// Features:
/// - Displays a list of required policy agreements (Personal, Service, Location)
/// - Allows users to read the full text of each policy
/// - Provides a "select all" option to quickly agree to all policies
/// - Tracks user selections and enables continuation only when all required terms are accepted
/// - Saves first-time installation status upon completion
///
/// After successful agreement to all terms, the user is redirected to the sign-in screen.
class PolicyScreen extends StatefulHookConsumerWidget {
  const PolicyScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends ConsumerState<PolicyScreen> {
  @override
  Widget build(BuildContext context) {
    final agressList = useState<List<TermType>>([]);

    final isAll = agressList.value.length == TermType.values.length;

    void agreeTerm(TermType type) {
      if (!agressList.value.contains(type)) {
        setState(() {
          agressList.value.add(type);
        });
      }
    }

    void unAgreeTerm(TermType type) {
      setState(() {
        agressList.value.remove(type);
      });
    }

    void checkAll(bool isAll) {
      setState(() {
        if (!isAll) {
          agressList.value.clear();
        } else {
          agressList.value.clear();
          agressList.value.addAll(TermType.values);

          setState(() {});
        }
      });
    }

    Future saveFirstTime() async {
      final localStorage = ref.watch(localStorageManagerProvider);
      localStorage.setValue<bool>(LocalStorageKeys.isFirstInstall, true);
    }

    return PopScope(
      canPop: false,
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 3.0,
        child: FullScreenScaffold(
          body: Scaffold(
            appBar: AppBar(
              title: Text(
                '회원가입',
                style: gpsTextStyle(
                  weight: FontWeight.w900,
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
              leading: const SizedBox(),
              backgroundColor: Colors.white,
            ),
            body: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ColoredBox(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: Sizes.screenPaddingV16,
                        horizontal: Sizes.screenPaddingH28,
                      ),
                      child: Column(
                        children: [
                          Flexible(
                            child: Image.asset(
                              MyAssets.ASSETS_IMAGES_CORE_APP_LOGO_PNG,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(
                            height: Sizes.marginV16,
                          ),
                          const Text(
                            ' 서비스 시작 및 가입을 위해 먼저 \n정보 제공에 동의해주세요.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF8A99AF),
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: Column(
                              children: [
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFf8f8f8),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: agressList.value.length ==
                                            TermType.values.length,
                                        onChanged: (value) {
                                          checkAll(value ?? false);
                                        },
                                        activeColor: const Color(0xFF1E386D),
                                      ),
                                      const Text(
                                        '약관 전체동의',
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(),
                                ...TermType.values.map(
                                  (type) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: _TermUse(
                                      type: type,
                                      agrList: agressList.value,
                                      onchange: (v) {
                                        if (v ?? false) {
                                          agreeTerm(type);
                                        } else {
                                          unAgreeTerm(type);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: isAll
                                        ? () {
                                            saveFirstTime();
                                            Navigator.of(context)
                                                .pushReplacement(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const SignInScreen(),
                                              ),
                                            );
                                          }
                                        : null,
                                    child: Text(
                                      '확인',
                                      style: gpsTextStyle(
                                        weight: FontWeight.w700,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TermUse extends StatefulWidget {
  const _TermUse({
    required this.type,
    required this.agrList,
    super.key,
    this.onchange,
  });

  final TermType type;
  final List<TermType> agrList;

  final Function(bool? v)? onchange;

  @override
  State<_TermUse> createState() => _TermUseState();
}

class _TermUseState extends State<_TermUse> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => _TermReadPage(termType: widget.type),
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Row(
            children: [
              Checkbox(
                value: widget.agrList.contains(widget.type),
                onChanged: widget.onchange,
                activeColor: const Color(0xFF1E386D),
              ),
              Text(
                '${widget.type.text} (필수)',
                style: gpsTextStyle(
                  weight: FontWeight.w700,
                  fontSize: 16,
                  lineHeight: 24,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios),
        ],
      ),
    );
  }
}

class _TermReadPage extends StatefulWidget {
  const _TermReadPage({required this.termType, super.key});

  final TermType termType;

  @override
  State<_TermReadPage> createState() => __TermReadPageState();
}

class __TermReadPageState extends State<_TermReadPage> {
  @override
  Widget build(BuildContext context) {
    final textStyle = gpsTextStyle(
      weight: FontWeight.w400,
      fontSize: 13,
      lineHeight: 15,
      color: Colors.black,
    );
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        title: Text(
          widget.termType.text,
          style: gpsTextStyle(
            weight: FontWeight.w900,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
      ),
      body: FutureBuilder(
        future: rootBundle.loadString(widget.termType.pathFile),
        builder: (context, snapshot) {
          return SingleChildScrollView(
            child: Html(
              data: snapshot.data ?? '',
              style: {
                '.p, p': Style.fromTextStyle(textStyle),
                '.s1, .s2, .s3': Style.fromTextStyle(textStyle),
                '.a, a': Style.fromTextStyle(textStyle),
                '.h1': Style.fromTextStyle(
                  textStyle.copyWith(fontWeight: FontWeight.w700),
                ),
              },
            ),
          );
        },
      ),
    );
  }
}
