import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;
class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
   List<GroceryItem> _groceryItems = [];
  var _isLoading=true;
  String? _error;

  @override
  void initState(){
    super.initState();
    _loadItem();
  }
  void _loadItem()async{
      final url=
    Uri.https('flutterproject-43e66-default-rtdb.firebaseio.com','shopping-list.json');
  try{
    final response=await http.get(url);
      
if(response.statusCode>=400){
  setState(() {
    _error='Failed to load data.Try later.';
  });
  
}
  if(response.body=='null'){
    setState(() {
      _isLoading=false;
    });
    return;
  }
  final Map<String,dynamic> listData=json.decode(response.body);
  final List<GroceryItem> _loadedItems=[];
  
  for(final item in listData.entries){
    final category=categories.entries.firstWhere(
      (catItem) => catItem.value.title==item.value['category']).value;
    _loadedItems.add(GroceryItem(
      id: item.key,
       name: item.value['name'], 
       quantity: item.value['quantity'], 
       category: category),);
  setState(() {
    _groceryItems=_loadedItems;
    _isLoading=false;
  });}
  }catch (err){
    setState(() {
      _error='Something went wrong.Try later.';
    });
  }
  

  
  }
  void _addItem() async {
   final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        
        builder: (ctx) => const NewItem(),
      ),
    );
  if(newItem==null){
    return;
  }
  setState(() {
    _groceryItems.add(newItem);
  });
    
  }
    

  void _removeItem(GroceryItem item) async{
    final index=_groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url=
    Uri.https(
      'flutterproject-43e66-default-rtdb.firebaseio.com','shopping-list/${item.id}.json');
    final response=await http.delete(url);

    if(response.statusCode>=400){
  setState(() {
   _groceryItems.insert(index, item);
  });
  
}
    
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text('No item added yet.',style: TextStyle(fontSize: 30,color: Colors.black),),
    );

if(_isLoading){
  content=const Center(child: CircularProgressIndicator(),);
}
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          background: Container(color: Colors.red),
          child:  Card(
            color: Color.fromARGB(91, 0, 0, 0),
            child: ListTile(
              title: Text(
                _groceryItems[index].name,
                style: TextStyle(color: Colors.white,fontSize: 20),
              ),
            leading: Container(
              width: 24,
              height: 24,
      
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(_groceryItems[index].quantity.toString(),style: TextStyle(fontSize: 20),),
          ),
        ),),
        );
    }
  if(_error!=null){
    content=Center(child: Text(_error!));
  }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ), body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/shopping.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: content,
      ),
      
    );
  }
}
