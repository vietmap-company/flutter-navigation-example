import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../map_screen/bloc/map_bloc.dart';
import '../map_screen/bloc/map_event.dart';
import '../map_screen/bloc/map_state.dart';
import 'components/search_address_header.dart';
import 'models/routing_header_model.dart';

class SearchAddress extends StatefulWidget {
  const SearchAddress({super.key});

  @override
  State<SearchAddress> createState() => _SearchAddressState();
}

class _SearchAddressState extends State<SearchAddress> {
  bool isSearchFromOrigin = true;
  String? addressText = '';
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var args =
          ModalRoute.of(context)?.settings.arguments as RoutingHeaderModel?;
      if (args != null) {
        setState(() {
          isSearchFromOrigin = args.isFromOrigin;
          addressText = args.addressText;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        body: Column(children: [
          SearchAddressHeader(
              isSearchFromOrigin: isSearchFromOrigin, addressText: addressText),
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
                              MapEventGetDetailAddress(state.response[index]));
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
                                title: Text(state.response[index].name ?? ''),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(state.response[index].address ?? ''),
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
        ]),
      ),
    );
  }
}
