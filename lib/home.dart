
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:app/recipe.dart';
import 'package:app/store.dart';
import 'package:app/card.dart';
import 'package:app/state.dart';
import 'package:app/state_widget.dart';
import 'package:app/login.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  StateModel appState;

  DefaultTabController _buildTabView({Widget body}) {
    const double _iconSize = 20.0;

    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: PreferredSize(
          // We set Size equal to passed height (50.0) and infinite width:
          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
            backgroundColor: Colors.cyan,
            elevation: 2.0,
            bottom: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              tabs: [
                Tab(icon: Icon(Icons.restaurant, size: _iconSize)),
                Tab(icon: Icon(Icons.restaurant_menu, size: _iconSize)),
                Tab(icon: Icon(Icons.fastfood, size: _iconSize)),
                Tab(icon: Icon(Icons.local_drink, size: _iconSize)),
                Tab(icon: Icon(Icons.cake, size: _iconSize)),
                Tab(icon: Icon(Icons.local_pizza, size: _iconSize)),
                Tab(icon: Icon(Icons.favorite, size: _iconSize)),
              ],
            ),  
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(5.0),
          child: body,
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (appState.isLoading) {
      return _buildTabView(
        body: _buildLoadingIndicator(),
      );
    } else if (!appState.isLoading && appState.user == null) {
      return new LoginScreen();
    } else {
      return _buildTabView(
        body: _buildTabsContent(),
      );
    }
  }

  Center _buildLoadingIndicator() {
    return Center(
      child: new CircularProgressIndicator(),
    );
  }

  TabBarView _buildTabsContent() {
    Padding _buildRecipes({RecipeType recipeType, List<String> ids}) {
      CollectionReference collectionReference =
          Firestore.instance.collection('recipes');
      Stream<QuerySnapshot> stream;
      // The argument recipeType is set
      if (recipeType != null) {
        stream = collectionReference
            .where("type", isEqualTo: recipeType.index)
            .snapshots();
      } else {
        // Use snapshots of all recipes if recipeType has not been passed
        stream = collectionReference.snapshots();
      }

      // Define query depeneding on passed args
      return Padding(
        // Padding before and after the list view:
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: new StreamBuilder(
                stream: stream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return _buildLoadingIndicator();
                  return new ListView(
                    children: snapshot.data.documents
                        // Check if the argument ids contains document ID if ids has been passed:
                        .where((d) => ids == null || ids.contains(d.documentID))
                        .map((document) {
                      return new RecipeCard(
                        recipe:
                            Recipe.fromMap(document.data, document.documentID),
                        inFavorites:
                            appState.favorites.contains(document.documentID),
                        onFavoriteButtonPressed: _handleFavoritesListChanged,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      children: [
        _buildRecipes(recipeType: RecipeType.food),
        _buildRecipes(recipeType: RecipeType.drink),
        Center(child: Icon(Icons.settings)),
        Center(child: Icon(Icons.settings)),
        Center(child: Icon(Icons.settings)),
        Center(child: Icon(Icons.settings)),
        _buildRecipes(ids: appState.favorites),
      ],
    );
  }

  // Inactive widgets are going to call this method to
  // signalize the parent widget HomeScreen to refresh the list view:
  void _handleFavoritesListChanged(String recipeID) {
    updateFavorites(appState.user.uid, recipeID).then((result) {
      // Update the state:
      if (result == true) {
        setState(() {
          if (!appState.favorites.contains(recipeID))
            appState.favorites.add(recipeID);
          else
            appState.favorites.remove(recipeID);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build the content depending on the state:
    appState = StateWidget.of(context).state;
    return _buildContent();
  }
}