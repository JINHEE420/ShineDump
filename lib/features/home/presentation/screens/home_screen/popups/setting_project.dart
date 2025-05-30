import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/presentation/helpers/localization_helper.dart';
import '../../../../../../core/presentation/utils/riverpod_framework.dart';
import '../../../../../../core/presentation/widgets/gps_text_field.dart';
import '../../../../../../core/presentation/widgets/loading_widgets.dart';
import '../../../../../../utils/style.dart';
import '../../../../domain/project.dart';
import '../../../components/retry_again_component.dart';
import '../../../providers/project_provider/project_provider.dart';

/// A widget that displays a popup for selecting a project from a list.
///
/// The `SettingProjectWidget` is a reusable component that allows users to
/// search and select a project from a list of projects. It supports a callback
/// mechanism to handle the selected project and provides an optional back button
/// for navigation.
///
/// ### Parameters:
/// - [callback]: A required function that is called when a project is selected.
///   The selected [Project] is passed as an argument.
/// - [siteId]: A required integer representing the ID of the site for which
///   projects are being fetched.
/// - [title]: A required string that specifies the title of the popup.
/// - [onBack]: An optional function that is called when the back button is pressed.
///
/// ### Features:
/// - Displays a list of projects fetched based on the provided [siteId].
/// - Includes a search bar to filter projects by name.
/// - Shows a loading indicator while fetching data and an error message with
///   a retry option if the fetch fails.
/// - Provides a clean and responsive UI with customizable styles.
///
/// ### Example Usage:
/// ```dart
/// SettingProjectWidget(
///   callback: (selectedProject) {
///     print('Selected project: ${selectedProject.name}');
///   },
///   siteId: 123,
///   title: 'Select a Project',
///   onBack: () {
///     print('Back button pressed');
///   },
/// );
/// ```

class SettingProjectWidget extends HookConsumerWidget {
  const SettingProjectWidget({
    required this.callback,
    required this.siteId,
    required this.title,
    super.key,
    this.onBack,
  });

  final Function(Project site) callback;
  final Function()? onBack;
  final String title;
  final int siteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchText = useState('');
    final size = MediaQuery.of(context).size;

    const style = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);

    final listProjectsState = ref.watch(
      listProjectStateProvider.call(siteId).select(
            (value) => value.whenData((value) => value),
          ),
    );
    return listProjectsState.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: !listProjectsState.hasError,
      loading: () => const TitledLoadingIndicator(message: ''),
      error: (error, st) => RetryAgainComponent(
        description: tr(context).systemErrorTryAgain,
        onPressed: () {
          ref.refresh(listProjectStateProvider.call(siteId));
        },
      ),
      data: (data) {
        final searchTxt = searchText.value.toLowerCase();
        final dataL = data
            .where((e) => e.name.toLowerCase().contains(searchTxt))
            .toList();

        return Container(
          height: size.height * .6,
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
              const SizedBox(height: 20),
              GpsTextField(
                bgColor: Colors.grey[200],
                borderColor: Colors.grey[200],
                hintText: tr(context).searchProject,
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
