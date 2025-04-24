import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/presentation/helpers/localization_helper.dart';
import '../../../../../../core/presentation/utils/riverpod_framework.dart';
import '../../../../../../core/presentation/widgets/gps_text_field.dart';
import '../../../../../../core/presentation/widgets/loading_widgets.dart';
import '../../../../../../utils/style.dart';
import '../../../../domain/area.dart';
import '../../../components/retry_again_component.dart';
import '../../../providers/area_provider/area_provider.dart';

/// A widget that displays a popup for selecting an unloading area.
///
/// This widget fetches and displays a list of unloading areas for a given project.
/// It allows users to search for specific areas and select one, triggering a callback
/// with the selected area.
///
/// The widget also handles loading, error, and retry states.
///
/// Example usage:
/// ```dart
/// SettingAreaUnloadingWidget(
///   callback: (area) {
///     // Handle the selected area
///   },
///   projectId: 123,
///   title: 'Select Unloading Area',
///   onBack: () {
///     // Handle back navigation
///   },
/// )
/// ```
class SettingAreaUnloadingWidget extends HookConsumerWidget {
  /// Creates a [SettingAreaUnloadingWidget].
  ///
  /// [callback] is a required function that is triggered when an area is selected.
  /// [projectId] is the ID of the project for which unloading areas are fetched.
  /// [title] is the title displayed at the top of the popup.
  /// [onBack] is an optional callback for handling back navigation.
  const SettingAreaUnloadingWidget({
    required this.callback,
    required this.projectId,
    required this.title,
    super.key,
    this.onBack,
  });

  /// Callback function triggered when an area is selected.
  final Function(Area id) callback;

  /// The ID of the project for which unloading areas are fetched.
  final int projectId;

  /// Optional callback for handling back navigation.
  final Function()? onBack;

  /// The title displayed at the top of the popup.
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchText = useState('');
    final size = MediaQuery.of(context).size;

    const style = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
    final listAreasState = ref.watch(
      listUnLoadingAreaStateProvider.call(projectId).select(
            (value) => value.whenData((value) => value),
          ),
    );
    return listAreasState.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: !listAreasState.hasError,
      loading: () => const TitledLoadingIndicator(message: ''),
      error: (error, st) => RetryAgainComponent(
        description: tr(context).systemErrorTryAgain,
        onPressed: () {
          ref.refresh(listUnLoadingAreaStateProvider.call(projectId));
        },
      ),
      data: (data) {
        final searchTxt = searchText.value.toLowerCase();
        final dataL = data
            .where((e) => e.name.toLowerCase().contains(searchTxt) ?? false)
            .toList();
        return Container(
          height: size.height * .5,
          width: size.width * .7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Stack(
                children: [
                  if (onBack != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: GestureDetector(
                          onTap: onBack,
                          child: const Icon(Icons.arrow_back_ios),
                        ),
                      ),
                    ),
                  Align(
                    child: Text(
                      title,
                      style: gpsTextStyle(
                        weight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: GestureDetector(
                        child: const Icon(Icons.close),
                        onTap: () {
                          context.pop();
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GpsTextField(
                bgColor: Colors.grey[200],
                borderColor: Colors.grey[200],
                hintText: tr(context).searchUnloadingPlace,
                onChanged: (v) {
                  searchText.value = v;
                },
              ),
              Container(
                padding: const EdgeInsets.only(top: 10),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: size.width * .7,
                height: 50,
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
                height: 0.5,
                color: Colors.grey.withOpacity(.5),
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  cacheExtent: 1000,
                  itemBuilder: (context, index) => InkWell(
                    onTap: () async {
                      callback.call(data[index]);
                    },
                    child: Container(
                      height: 55,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: ListTile(
                        title: Text(
                          dataL[index].name,
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
