import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_words/di/service_locator.dart';
import 'package:my_words/presentation/favorite/favorite_screen.dart';
import 'package:my_words/presentation/home/home_view_model.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeViewModel model = serviceLocator<HomeViewModel>();
  TextEditingController? _controller;

  @override
  void initState() {
    model.loadData();
    _controller = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeViewModel>(
      create: (context) => model,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Provider Demo"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.favorite),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoriteScreen()),
                );
                model.refreshFavorites();
              },
            )
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Selector<HomeViewModel, CurrencyPresentation>(
                selector: (context, model) => model.baseCurrency,
                builder: (context, data, child) => baseCurrencyTitle(model)),
            Selector<HomeViewModel, CurrencyPresentation>(
                selector: (context, model) => model.baseCurrency,
                builder: (context, data, child) =>
                    baseCurrencyTextField(model)),
            Selector<HomeViewModel, List<CurrencyPresentation>>(
                selector: (context, model) => model.quoteCurrencies,
                builder: (context, data, child) => quoteCurrencyList(model),
                shouldRebuild: (previous, next) => true)
          ],
        ),
      ),
    );
  }

  Widget baseCurrencyTitle(HomeViewModel model) {
    print("come title");
    return Padding(
        padding: const EdgeInsets.only(left: 32, top: 32, right: 32, bottom: 5),
        child: Text(
          '${model.baseCurrency.longName}',
          style: TextStyle(fontSize: 25),
        ));
  }

  Padding baseCurrencyTextField(HomeViewModel model) {
    print("come textfield");
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: TextField(
          style: TextStyle(fontSize: 18),
          controller: _controller,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 25),
              child: SizedBox(
                width: 20,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${model.baseCurrency.flag}',
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ),
            ),
            labelStyle: TextStyle(fontSize: 18),
            hintStyle: TextStyle(fontSize: 18),
            hintText: 'Amount to exchange',
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(15),
          ),
          keyboardType: TextInputType.number,
          onChanged: (text) {
            model.calculateExchange(text);
          },
        ),
      ),
    );
  }

  Expanded quoteCurrencyList(HomeViewModel model) {
    print("come list");
    return Expanded(
      child: ListView.builder(
        itemCount: model.quoteCurrencies.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: SizedBox(
                width: 60,
                child: Text(
                  '${model.quoteCurrencies[index].flag}',
                  style: TextStyle(fontSize: 30),
                ),
              ),
              title: Text(model.quoteCurrencies[index].longName ?? ""),
              subtitle: Text(model.quoteCurrencies[index].amount ?? ""),
              onTap: () {
                model.setNewBaseCurrency(index);
                _controller?.clear();
              },
            ),
          );
        },
      ),
    );
  }
}
