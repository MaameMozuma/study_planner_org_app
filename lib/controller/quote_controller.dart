import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:study_master/model/quote.dart';

class QuoteController{

  Future<Quote> getQuote() async{
    final response = await http.get(Uri.parse('https://favqs.com/api/qotd'));

    if (response.statusCode == 200){
      return Quote.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load quote');
    }
  }
  
}