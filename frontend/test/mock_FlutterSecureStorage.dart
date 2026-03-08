import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/data/repositories/impl/secure_storage_repository_imp.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureStorageRepositoryImp repository;
  
  // Dựa vào log của bạn: Key thực tế là 'JWT_TOKEN'
  const String jwtKey = 'JWT_TOKEN'; 

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    repository = SecureStorageRepositoryImp(mockStorage);
  });

  group('SecureStorageRepository - deleteToken', () {
    
    test('nên gọi hàm delete của storage với đúng key khi gọi deleteToken', () async {
      // SỬA LỖI 2: Đảm bảo trả về Future<void> thay vì Null
      when(() => mockStorage.delete(
        key: any(named: 'key'),
        iOptions: any(named: 'iOptions'),
        aOptions: any(named: 'aOptions'),
        lOptions: any(named: 'lOptions'),
        webOptions: any(named: 'webOptions'),
        mOptions: any(named: 'mOptions'),
        wOptions: any(named: 'wOptions'),
      )).thenAnswer((_) async => {});

      // Act
      await repository.deleteToken();

      // Assert
      // SỬA LỖI 1: Khớp chính xác key 'JWT_TOKEN'
      verify(() => mockStorage.delete(key: jwtKey)).called(1);
    });

    test('nên ném ra Exception nếu hàm delete của storage bị lỗi', () async {
      // Arrange
      // Phải chỉ định rõ hành vi throw, nếu không nó lại bị lỗi Null type như trên
      when(() => mockStorage.delete(
        key: any(named: 'key'),
        iOptions: any(named: 'iOptions'),
        aOptions: any(named: 'aOptions'),
        lOptions: any(named: 'lOptions'),
        webOptions: any(named: 'webOptions'),
        mOptions: any(named: 'mOptions'),
        wOptions: any(named: 'wOptions'),
      )).thenThrow(Exception('Storage Error'));

      // Act & Assert
      // Lưu ý: Với hàm async, dùng throwsA và wrap trong expect Later hoặc dùng closure
      expect(() => repository.deleteToken(), throwsA(isA<Exception>()));
    });
  });
}