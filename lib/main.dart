// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (_) => PersonsBloc(),
        child: HomePage(),
      ),
    ),
  );
}

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPersonsAction extends LoadAction {
  final PersonUrl url;
  const LoadPersonsAction({required this.url}) : super();
}

enum PersonUrl {
  person1,
  person2,
}

extension UrlString on PersonUrl {
  String get urlString {
    switch (this) {
      case PersonUrl.person1:
        return "http://10.0.2.2:5500/api/persons1.json";
      case PersonUrl.person2:
        return "http://10.0.2.2:5500/api/persons2.json";
    }
  }
}

@immutable
class Person {
  final String name;
  final int age;

  const Person({required this.name, required this.age});
  Person.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        age = json['age'] as int;
}

Future<Iterable<Person>> getPersons(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((resp) => resp.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then((list) => list.map((e) => Person.fromJson(e)));

@immutable
class FetchResult {
  final Iterable<Person> persons;
  final bool isRetrievedFromCache;

  const FetchResult(
      {required this.persons, required this.isRetrievedFromCache});

  @override
  String toString() =>
      'FetchResult (isRetrievedFromCache = $isRetrievedFromCache, persons = $persons)';
}

class PersonsBloc extends Bloc<LoadAction, FetchResult?> {
  final Map<PersonUrl, Iterable<Person>> _cache = {};
  PersonsBloc() : super(null) {
    on<LoadPersonsAction>((event, emit) async {
      final url = event.url;
      if (_cache.containsKey(url)) {
        final cashedPersons = _cache[url];
        final result =
            FetchResult(persons: cashedPersons!, isRetrievedFromCache: true);
        emit(result);
      } else {
        final persons = await getPersons(url.urlString);
        _cache[url] = persons;
        final result =
            FetchResult(persons: persons, isRetrievedFromCache: false);
        emit(result);
      }
    });
  }
}

extension Subscript<T> on Iterable<T> {
  T? operator [](int index) => length > index ? elementAt(index) : null;
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  context
                      .read<PersonsBloc>()
                      .add(LoadPersonsAction(url: PersonUrl.person1));
                },
                child: Text('Load json #1'),
              ),
              TextButton(
                onPressed: () {
                  context
                      .read<PersonsBloc>()
                      .add(LoadPersonsAction(url: PersonUrl.person2));
                },
                child: Text('Load json #2'),
              ),
            ],
          ),
          BlocBuilder<PersonsBloc, FetchResult?>(
            buildWhen: (previousResult, currentResult) {
              return previousResult?.persons != currentResult?.persons;
            },
            builder: ((context, fetchResult) {
              final persons = fetchResult?.persons;
              if (persons == null) {
                return SizedBox();
              }
              return Expanded(
                child: ListView.builder(
                    itemCount: persons.length,
                    itemBuilder: (context, index) {
                      final person = persons[index]!;
                      return ListTile(
                        title: Text(person.name),
                      );
                    }),
              );
            }),
          ),
        ],
      ),
    );
  }
}
