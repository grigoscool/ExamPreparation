
&НаКлиенте
Процедура СписокНоменклатурыКоличествоПриИзменении(Элемент)
	СтрокаТЧ = Элементы.СписокНоменклатуры.ТекущиеДанные;
	СтрокаТЧ.Сумма = СтрокаТЧ.Количество * СтрокаТЧ.Цена;
КонецПроцедуры

&НаКлиенте
Процедура СписокНоменклатурыЦенаПриИзменении(Элемент)
	СтрокаТЧ = Элементы.СписокНоменклатуры.ТекущиеДанные;
	СтрокаТЧ.Сумма = СтрокаТЧ.Количество * СтрокаТЧ.Цена;
КонецПроцедуры
