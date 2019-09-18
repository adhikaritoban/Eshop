import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  //manage which form is focus current, give for transition from text form filed to other text form field
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  //form manages value but we need preview of image then only submit form so we create our own controller
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();

  //hold global key for form, and allow to manage form state
  final _form = GlobalKey<FormState>();

  //not final, get Product Property and initalize
  var _editedProduct = Product(
    id: null,
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );

  //initial value for new product
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  //to check the state of this page
  var _isInit = true;

  //for checking if response is arrived or not , if not show progress bar
  var _isLoading = false;

  @override
  void initState() {
    // if image url text form field changes the focus or not
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // if init is true get arguments from the user product item and get product id
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;

      //check if product exist for edit or add new product
      if (productId != null) {
        //find only one element using findById method
        _editedProduct = Provider.of<ProductsProvider>(context, listen: false)
            .findById(productId);

        //_editedProduct = product;

        //new map for values if product edit button pressed
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          // 'imageUrl': _editedProduct.imageUrl,
          'imageUrl': '',
        };

        //for showing image if edit button pressed
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    // _isInit = false , so to we do not re initalize form , didChange runs multiple times
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    //remove listener from _imageUrlFocusNode before focus node dispose
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    //then dispose focus
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  //get preview if focus has been changed from image url text field
  void _updateImageUrl() {
    //if image focus node has not been focused
    if (!_imageUrlFocusNode.hasFocus) {
      //do not show image with invalid url
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      //update the ui and saved the latest imageurlcontroller state if not has focus
      setState(() {});
    }
  }

  /*save form*/
  Future<void> _saveForm() async {
    //for validation
    final isValid = _form.currentState.validate();
    //if form is not valid return else save the _form data
    if (!isValid) {
      return;
    }
    //get direct access of form in here and get current state and get value from every text field and save form
    _form.currentState.save();
    //change isLoading to true, and reflect that change using setState in the ui
    setState(() {
      _isLoading = true;
    });
    //check if _editedProduct has an id or not
    if (_editedProduct.id != null) {
      //we now edit and update existing product.
      //inorder to change data appearance to server and here await for future
      await Provider.of<ProductsProvider>(context, listen: false).updateProduct(
        _editedProduct.id,
        _editedProduct,
      );
      //if done then set isLoading to false
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      try {
        /*add new product to the products provider class*/
        //if addProduct will return future, then we can use that future and then only pop screen
        await Provider.of<ProductsProvider>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        //for show error to user
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occured'),
            content: Text('Something went wrong'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Ok')),
            ],
          ),
        );
      }

      //if done then set isLoading to false
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),

            //for submitting form here number 1
            onPressed: _saveForm,
          ),
        ],
      ),
      //if isLoading is true then show progress bar
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                //global key, will interact with the text form fields from functions or from inside your code
                key: _form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      //if edit button is tap and productId is not null
                      initialValue: _initValues['title'],
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,

                      //unless keyboard is not press,,, (argument we can get value from this text form field_
                      onFieldSubmitted: (_) {
                        //request focus to next text form field of price
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a value.';
                        }
                        return null;
                      },
                      //on save get value from each text form field
                      onSaved: (value) {
                        _editedProduct = Product(
                            title: value,
                            price: _editedProduct.price,
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a price.';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number.';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please enter a number greater than zero.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            title: _editedProduct.title,
                            price: double.parse(value),
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a description.';
                        }
                        if (value.length < 10) {
                          return 'Should be at least 10 characters long.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          price: _editedProduct.price,
                          description: value,
                          imageUrl: _editedProduct.imageUrl,
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Enter a URL')
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,

                            //controller gets updated and provide above container with image preview
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,

                            //for submitting form here number 2
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter an image URL.';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Please enter a valid URL.';
                              }
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('.jpg') &&
                                  !value.endsWith('.jpeg')) {
                                return 'Please enter a valid image URL.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editedProduct = Product(
                                title: _editedProduct.title,
                                price: _editedProduct.price,
                                description: _editedProduct.description,
                                imageUrl: value,
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
