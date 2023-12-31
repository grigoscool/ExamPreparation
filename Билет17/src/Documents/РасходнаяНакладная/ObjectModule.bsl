
Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	СуммаПоДокументу = СписокНоменклатуры.Итог("Сумма");
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	Отдел  = Справочники.Подразделения.ОтделЗакупок;
	//записать движ
	Движения.ОстаткиНоменклатуры.Записывать = Истина;
	Движения.Записать();
	Движения.ОстаткиНоменклатуры.Записывать = Истина;
	//Блокировкад
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрНакопления.ОстаткиНоменклатуры");
	ЭлементБлокировки.УстановитьЗначение("Подразделение", ТорговаяТочка);
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	ЭлементБлокировки.ИсточникДанных = СписокНоменклатуры;
	ЭлементБлокировки.ИспользоватьИзИсточникаДанных("Номенклатура", "Номенклатура");
	Блокировка.Заблокировать(); 
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрНакопления.ОстаткиНоменклатуры");
	ЭлементБлокировки.УстановитьЗначение("Подразделение", Отдел);
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	ЭлементБлокировки.ИсточникДанных = СписокНоменклатуры;
	ЭлементБлокировки.ИспользоватьИзИсточникаДанных("Номенклатура", "Номенклатура");
	Блокировка.Заблокировать(); 
	//старая метода
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура КАК Номенклатура,
		|	СУММА(РасходнаяНакладнаяСписокНоменклатуры.Количество) КАК Количество,
		|	СУММА(РасходнаяНакладнаяСписокНоменклатуры.Сумма) КАК Сумма
		|ПОМЕСТИТЬ втТЧТовары
		|ИЗ
		|	Документ.РасходнаяНакладная.СписокНоменклатуры КАК РасходнаяНакладнаяСписокНоменклатуры
		|ГДЕ
		|	РасходнаяНакладнаяСписокНоменклатуры.Ссылка = &Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Номенклатура
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	втТЧТовары.Номенклатура КАК Номенклатура,
		|	втТЧТовары.Номенклатура.Представление КАК НоменклатураПредставление,
		|	втТЧТовары.Количество КАК Количество,
		|	ОстаткиНоменклатурыВОтделе.КоличествоОстаток КАК КоличествоОстатокОт,
		|	ОстаткиНоменклатурыВОтделе.СебестоимостьОстаток КАК СебестоимостьОстатокОт,
		|	ОстаткиНоменклатурыВТочке.КоличествоОстаток КАК КоличествоОстатокТ,
		|	ОстаткиНоменклатурыВТочке.СебестоимостьОстаток КАК СебестоимостьОстатокТ,
		|	втТЧТовары.Номенклатура.ПроцентНаценки КАК ПроцентНаценки
		|ИЗ
		|	втТЧТовары КАК втТЧТовары,
		|	РегистрНакопления.ОстаткиНоменклатуры.Остатки(
		|			&МоментВремени,
		|			Подразделение = &Точка
		|				И Номенклатура В
		|					(ВЫБРАТЬ
		|						втТЧТовары.Номенклатура КАК Номенклатура
		|					ИЗ
		|						втТЧТовары КАК втТЧТовары)) КАК ОстаткиНоменклатурыВТочке,
		|	РегистрНакопления.ОстаткиНоменклатуры.Остатки(
		|			&МоментВремени,
		|			Подразделение = &Отдел
		|				И Номенклатура В
		|					(ВЫБРАТЬ
		|						втТЧТовары.Номенклатура КАК Номенклатура
		|					ИЗ
		|						втТЧТовары КАК втТЧТовары)) КАК ОстаткиНоменклатурыВОтделе";
	
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени());
	Запрос.УстановитьПараметр("Отдел", Отдел);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("Точка", ТорговаяТочка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Если Выборка.Количество > Выборка.КоличествоОстатокОт + Выборка.КоличествоОстатокТ Тогда
		     Отказ = истина;
			 Сообщение = Новый СообщениеПользователю;
			 Сообщение.Текст = стршаблон("не хватает %1 в кол-ве %2 ед.",
			 							Выборка.НоменклатураПредставление,
										Выборка.Количество - Выборка.КоличествоОстатокОт - Выборка.КоличествоОстатокТ);
			 Сообщение.Сообщить();
		 КонецЕсли;  
		 Если Отказ Тогда
		 	Продолжить;
		КонецЕсли; 
		Если Выборка.Количество > Выборка.КоличествоОстатокТ Тогда
		
			
			Движение = Движения.ОстаткиНоменклатуры.ДобавитьРасход();
			Движение.Период = Дата;
			Движение.Номенклатура = Выборка.Номенклатура;
			Движение.Подразделение = Отдел;
			КоличествоСписать = Выборка.Количество - Выборка.КоличествоОстатокТ;
			Движение.Количество = КоличествоСписать;
			Себестоимость = (Выборка.СебестоимостьОстатокОт / Выборка.КоличествоОстатокОт * КоличествоСписать);
			Движение.Себестоимость = Себестоимость;	
			
			Движение = Движения.ОстаткиНоменклатуры.ДобавитьПриход();
			Движение.Период = Дата;
			Движение.Номенклатура = Выборка.Номенклатура;
			Движение.Подразделение = ТорговаяТочка;
			Движение.Количество = КоличествоСписать;
			Движение.Себестоимость = Себестоимость + Себестоимость * Выборка.ПроцентНаценки / 100;				
		
		КонецЕсли;
		Движение = Движения.ОстаткиНоменклатуры.ДобавитьРасход();
		Движение.Период = Дата;
		Движение.Номенклатура = Выборка.Номенклатура;
		Движение.Подразделение = ТорговаяТочка;
		Движение.Количество = Выборка.Количество;
		Себестоимость = (Выборка.СебестоимостьОстатокТ / Выборка.КоличествоОстатокТ * Выборка.Количество);
		Движение.Себестоимость = Себестоимость;	
	КонецЦикла;
КонецПроцедуры
