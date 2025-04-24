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

/// A widget that displays a popup for selecting an area from a list of areas.
///
/// This widget fetches a list of areas based on the provided `projectId` and
/// allows the user to search and select an area. The selected area is passed
/// back using the `callback` function.
///
/// The widget also supports an optional back button and a title for the popup.
class SettingAreaWidget extends HookConsumerWidget {
  /// Creates a [SettingAreaWidget].
  ///
  /// - [callback]: A function that is called when an area is selected.
  /// - [projectId]: The ID of the project for which areas are fetched.
  /// - [title]: The title displayed at the top of the popup.
  /// - [onBack]: An optional function that is called when the back button is pressed.
  const SettingAreaWidget({
    required this.callback,
    required this.projectId,
    required this.title,
    super.key,
    this.onBack,
  });

  /// A callback function that is triggered when an area is selected.
  /// The selected [Area] is passed as an argument.
  final Function(Area id) callback;

  /// The ID of the project for which the list of areas is fetched.
  final int projectId;

  /// An optional function that is triggered when the back button is pressed.
  final Function()? onBack;

  /// The title displayed at the top of the popup.
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchText = useState('');
    final size = MediaQuery.of(context).size;

    const style = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
    final listAreasState = ref.watch(
      listAreaStateProvider.call(projectId).select(
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
          ref.refresh(listAreaStateProvider.call(projectId));
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
              Row(
                children: [
                  const SizedBox(width: 10),
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
                hintText: tr(context).searchLoadingPlace,
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
                color: Colors.grey.withOpacity(.5),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(0),
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
