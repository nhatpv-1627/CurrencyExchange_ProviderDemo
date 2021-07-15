import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_words/di/service_locator.dart';
import 'package:my_words/presentation/favorite/favorite_view_model.dart';
import 'package:provider/provider.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  FavoriteViewModel model = serviceLocator<FavoriteViewModel>();

  @override
  void initState() {
    model.loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorite Currencies"),
      ),
      body: _buildListView(model),
    );
  }

  Widget _buildListView(FavoriteViewModel viewModel) {
    return ChangeNotifierProvider<FavoriteViewModel>(
      create: (context) => viewModel,
      child: Consumer<FavoriteViewModel>(
          builder: (context, model, child) => ListView.builder(
                itemCount: model.choices.length,
                itemBuilder: (context, index) => Card(
                    child: ListTile(
                  leading: SizedBox(
                    width: 60,
                    child: Text(
                      '${model.choices[index].flag}',
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                  title: Text('${model.choices[index].alphabeticCode}'),
                  subtitle: Text('${model.choices[index].longName}'),
                  trailing: (model.choices[index].isFavorite == true)
                      ? Icon(Icons.favorite, color: Colors.red)
                      : Icon(Icons.favorite_border),
                  onTap: () => {model.toggleFavoriteStatus(index)},
                )),
              )),
    );
  }
}
