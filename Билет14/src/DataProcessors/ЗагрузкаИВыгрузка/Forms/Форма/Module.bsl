
&НаКлиенте
Процедура ИмяФайлаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ДиалогВыбора = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДиалогВыбора.Заголовок = "Выберите файл";
	
	Если ДиалогВыбора.Выбрать() Тогда
		ИмяФайла = ДиалогВыбора.ПолноеИмяФайла;
	КонецЕсли;

КонецПроцедуры
