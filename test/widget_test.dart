import 'package:flutter_test/flutter_test.dart';
import 'package:kisan_hisab/utils/calculations.dart';
import 'package:kisan_hisab/models/entry_model.dart';
import 'package:kisan_hisab/models/person_model.dart';
import 'package:kisan_hisab/config/constants.dart';

void main() {
  group('AppCalculations', () {
    test('kapasAmount calculates weight * rate', () {
      expect(AppCalculations.kapasAmount(10, 500), 5000);
      expect(AppCalculations.kapasAmount(0, 500), 0);
      expect(AppCalculations.kapasAmount(2.5, 1000), 2500);
    });

    test('paaniAmount calculates hours * rate', () {
      expect(AppCalculations.paaniAmount(5, 200), 1000);
      expect(AppCalculations.paaniAmount(0, 200), 0);
      expect(AppCalculations.paaniAmount(1.5, 400), 600);
    });

    test('mazdoorAmount calculates days * rate', () {
      expect(AppCalculations.mazdoorAmount(10, 300), 3000);
      expect(AppCalculations.mazdoorAmount(0, 300), 0);
      expect(AppCalculations.mazdoorAmount(2.5, 400), 1000);
    });

    test('netBalance calculates correctly', () {
      // toReceive - received - (toPay - paid)
      expect(AppCalculations.netBalance(toReceive: 1000, toPay: 500, received: 200, paid: 100), 400);
      expect(AppCalculations.netBalance(toReceive: 0, toPay: 0, received: 0, paid: 0), 0);
      expect(AppCalculations.netBalance(toReceive: 1000, toPay: 1000, received: 0, paid: 0), 0);
    });
  });

  group('PersonModel', () {
    test('netBalance calculates totalToReceive - totalToPay', () {
      final person = PersonModel(
        id: '1',
        name: 'Test',
        totalToReceive: 1000,
        totalToPay: 300,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(person.netBalance, 700);
      expect(person.isToReceive, true);
    });

    test('isToReceive is false when netBalance negative', () {
      final person = PersonModel(
        id: '1',
        name: 'Test',
        totalToReceive: 300,
        totalToPay: 1000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(person.netBalance, -700);
      expect(person.isToReceive, false);
    });

    test('copyWith updates fields correctly', () {
      final person = PersonModel(
        id: '1',
        name: 'Original',
        totalToReceive: 100,
        totalToPay: 50,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final updated = person.copyWith(name: 'Updated', totalToReceive: 200);
      expect(updated.name, 'Updated');
      expect(updated.totalToReceive, 200);
      expect(updated.totalToPay, 50); // unchanged
      expect(updated.id, '1'); // unchanged
    });

    test('toMap and fromMap work correctly', () {
      final now = DateTime.now();
      final person = PersonModel(
        id: '1',
        name: 'Test',
        phone: '1234567890',
        address: 'Test Address',
        note: 'Test Note',
        photoBase64: 'base64string',
        totalToReceive: 500,
        totalToPay: 200,
        createdAt: now,
        updatedAt: now,
      );

      final map = person.toMap();
      expect(map['name'], 'Test');
      expect(map['phone'], '1234567890');
      expect(map['totalToReceive'], 500);
      expect(map['totalToPay'], 200);
    });
  });

  group('EntryModel', () {
    test('isToReceive returns true for kapas, paani, paymentPay', () {
      final kapasEntry = EntryModel(
        id: '1',
        type: EntryTypes.kapas,
        date: DateTime.now(),
        amount: 1000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(kapasEntry.isToReceive, true);

      final paaniEntry = EntryModel(
        id: '2',
        type: EntryTypes.paani,
        date: DateTime.now(),
        amount: 500,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(paaniEntry.isToReceive, true);

      final paymentPayEntry = EntryModel(
        id: '3',
        type: EntryTypes.paymentPay,
        date: DateTime.now(),
        amount: 200,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(paymentPayEntry.isToReceive, true);
    });

    test('isToPay returns true for mazdoori, expense, paymentReceive', () {
      final mazdooriEntry = EntryModel(
        id: '1',
        type: EntryTypes.mazdoori,
        date: DateTime.now(),
        amount: 1000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(mazdooriEntry.isToPay, true);

      final expenseEntry = EntryModel(
        id: '2',
        type: EntryTypes.expense,
        date: DateTime.now(),
        amount: 500,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(expenseEntry.isToPay, true);

      final paymentReceiveEntry = EntryModel(
        id: '3',
        type: EntryTypes.paymentReceive,
        date: DateTime.now(),
        amount: 200,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(paymentReceiveEntry.isToPay, true);
    });

    test('toMap and fromMap work correctly', () {
      final now = DateTime.now();
      final entry = EntryModel(
        id: '1',
        type: EntryTypes.kapas,
        personId: 'person1',
        personName: 'John',
        date: now,
        amount: 1000,
        note: 'Test note',
        typeData: {'weight': 10, 'rate': 100, 'unit': 'Mann'},
        createdAt: now,
        updatedAt: now,
      );

      final map = entry.toMap();
      expect(map['type'], EntryTypes.kapas);
      expect(map['personId'], 'person1');
      expect(map['amount'], 1000);
      expect(map['typeData']['weight'], 10);

      final restored = EntryModel.fromMap('1', map);
      expect(restored.type, EntryTypes.kapas);
      expect(restored.amount, 1000);
      expect(restored.typeData['weight'], 10);
    });

    test('copyWith updates fields correctly', () {
      final entry = EntryModel(
        id: '1',
        type: EntryTypes.kapas,
        date: DateTime.now(),
        amount: 1000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final updated = entry.copyWith(amount: 2000, note: 'Updated note');
      expect(updated.amount, 2000);
      expect(updated.note, 'Updated note');
      expect(updated.type, EntryTypes.kapas); // unchanged
    });
  });

  group('Constants', () {
    test('EntryTypes constants are defined', () {
      expect(EntryTypes.kapas, 'kapas');
      expect(EntryTypes.paani, 'paani');
      expect(EntryTypes.mazdoori, 'mazdoori');
      expect(EntryTypes.expense, 'expense');
      expect(EntryTypes.paymentReceive, 'payment_receive');
      expect(EntryTypes.paymentPay, 'payment_pay');
    });

    test('AppCategories lists are not empty', () {
      expect(AppCategories.workTypes, isNotEmpty);
      expect(AppCategories.expenseCategories, isNotEmpty);
      expect(AppCategories.paymentMethods, isNotEmpty);
      expect(AppCategories.crops, isNotEmpty);
    });
  });
}