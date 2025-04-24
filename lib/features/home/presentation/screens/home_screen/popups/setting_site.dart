import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/presentation/helpers/localization_helper.dart';
import '../../../../../../core/presentation/utils/riverpod_framework.dart';
import '../../../../../../core/presentation/widgets/gps_text_field.dart';
import '../../../../../../core/presentation/widgets/loading_widgets.dart';
import '../../../../../../utils/style.dart';
import '../../../../domain/site.dart';
import '../../../components/retry_again_component.dart';
import '../../../providers/site_provider/site_provider.dart';

/// A widget that displays a popup for selecting a site from a list of available sites.
///
/// This widget provides a search functionality to filter the list of sites
/// and allows the user to select a site, triggering a callback with the selected site.
///
/// The widget also supports an optional back button and a close button.
///
/// Example usage:
/// ```dart
/// SettingSiteWidget(
///   title: 'Select Site',
///   callback: (site) {
///     print('Selected site: ${site.name}');
///   },
///   onBack: () {
///     print('Back button pressed');
///   },
/// )
/// ```
class SettingSiteWidget extends HookConsumerWidget {
  /// Creates a [SettingSiteWidget].
  ///
  /// [callback] is a required function that is called when a site is selected.
  /// [title] is the title displayed at the top of the popup.
  /// [onBack] is an optional function that is called when the back button is pressed.
  SettingSiteWidget({
    required this.callback,
    required this.title,
    super.key,
    this.onBack,
  });

  /// Callback function triggered when a site is selected.
  /// The selected [Site] is passed as an argument.
  final Function(Site site) callback;

  /// Optional callback function triggered when the back button is pressed.
  final Function()? onBack;

  /// The title displayed at the top of the popup.
  final String title;

  /// Controller for managing the text input in the search field.
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchText = useState('');
    final size = MediaQuery.of(context).size;

    const style = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);

    final loadingSiteState = ref.watch(
      listSiteStateProvider.select((value) => value.whenData((value) => value)),
    );

    return loadingSiteState.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: !loadingSiteState.hasError,
      loading: () => const TitledLoadingIndicator(message: ''),
      error: (error, st) => RetryAgainComponent(
        description: tr(context).systemErrorTryAgain,
        onPressed: () {
          ref.refresh(listSiteStateProvider);
        },
      ),
      data: (List<Site> data) {
        final searchTxt = searchText.value.toLowerCase();
        final dataL = data
            .where((e) => e.name?.toLowerCase().contains(searchTxt) ?? false)
            .toList();
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          height: size.height * .55,
          width: size.width * .7,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  if (onBack == null)
                    const SizedBox(width: 25)
                  else
                    GestureDetector(
                      onTap: onBack,
                      child: const Icon(Icons.arrow_back_ios),
                    ),
                  Expanded(
                    child: Text(
                      title,
                      style: gpsTextStyle(
                        weight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    child: const Icon(Icons.close),
                    onTap: () {
                      context.pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GpsTextField(
                bgColor: Colors.grey[200],
                borderColor: Colors.grey[200],
                hintText: tr(context).searchHeadquarters,
                onChanged: (v) {
                  searchText.value = v;
                },
              ),
              Container(
                padding: const EdgeInsets.only(top: 10),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: size.width * .7,
                alignment: Alignment.centerLeft,
                child: Text(
                  tr(context).requestList(dataL.length),
                  style: style.copyWith(
                    color: const Color(0xFF352555),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Divider(
                thickness: .5,
                color: Colors.grey.withOpacity(.5),
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemBuilder: (context, index) => InkWell(
                    onTap: () async {
                      callback.call(dataL[index]);
                    },
                    child: Container(
                      height: 55,
                      width: double.infinity,
                      alignment: Alignment.center,
                      color: Colors.white,
                      child: ListTile(
                        title: Text(
                          dataL[index].name ?? '',
                          style: style,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  separatorBuilder: (context, index) => Divider(
                    height: 2,
                    thickness: 1,
                    color: Colors.grey.withOpacity(.8),
                  ),
                  itemCount: dataL.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
