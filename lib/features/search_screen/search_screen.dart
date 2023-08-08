import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vietmap_map/components/debouncer_search.dart';

import '../map_screen/bloc/map_bloc.dart';
import '../map_screen/bloc/map_event.dart';
import '../map_screen/bloc/map_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FocusNode _focusNode = FocusNode();
  final Debounce _debounce = Debounce();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500));
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              const SizedBox(height: 10),
              Hero(
                tag: 'searchBar',
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  width: MediaQuery.of(context).size.width - 40,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        _debounce.run(() {
                          context
                              .read<MapBloc>()
                              .add(MapEventSearchAddress(address: value));
                        });
                      }
                    },
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.grey)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.grey)),
                        prefixIcon: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.black54,
                          ),
                        ),
                        hintText: 'Nhập từ khoá để tìm kiếm',
                        contentPadding: const EdgeInsets.only(top: 15),
                        hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 17,
                            fontWeight: FontWeight.w400)),
                  ),
                ),
              ),
              BlocBuilder<MapBloc, MapState>(buildWhen: (previous, current) {
                if (current is MapStateSearchAddressSuccess) {
                  return true;
                }
                return false;
              }, builder: (_, state) {
                if (state is MapStateSearchAddressSuccess) {
                  return Expanded(
                    child: ListView.builder(
                        itemCount: state.response.length,
                        itemBuilder: (_, index) {
                          return InkWell(
                            onTap: () {
                              context.read<MapBloc>().add(
                                  MapEventGetDetailAddress(
                                      placeId:
                                          state.response[index].refId ?? ''));
                              FocusScope.of(context).requestFocus(FocusNode());
                              Navigator.pop(context);
                            },
                            child: Row(
                              children: [
                                const SizedBox(width: 10),
                                const Icon(Icons.location_pin,
                                    color: Colors.black54),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Hero(
                                        tag: state.response[index].name ??
                                            'addressName',
                                        child: Text(
                                            state.response[index].name ?? '')),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Hero(
                                          tag: state.response[index].address ??
                                              '',
                                          child: Text(
                                              state.response[index].address ??
                                                  ''),
                                        ),
                                        const Divider()
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              })
            ],
          ),
        ),
      ),
    );
  }
}
