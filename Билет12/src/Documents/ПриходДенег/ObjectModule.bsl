
Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	Движения.Взаиморасчеты.Записывать = Истина;
	Движения.Взаиморасчеты.Записать();
	Движения.Взаиморасчеты.Записывать = Истина;
	
	//блокировкад
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрНакопления.Взаиморасчеты");
	ЭлементБлокировки.УстановитьЗначение("Контрагент", Контрагент);
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	Блокировка.Заблокировать();	
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВзаиморасчетыОстатки.Контрагент КАК Контрагент,
		|	ВзаиморасчетыОстатки.Проект КАК Проект,
		|	ВзаиморасчетыОстатки.Валюта КАК Валюта,
		|	ВзаиморасчетыОстатки.СуммаВРубляхОстаток КАК СуммаВРубляхОстаток,
		|	ВзаиморасчетыОстатки.СуммаВВалютеОстаток КАК СуммаВВалютеОстаток
		|ПОМЕСТИТЬ втДолгиПоПроектам
		|ИЗ
		|	РегистрНакопления.Взаиморасчеты.Остатки(&МоментВремени, Контрагент = &Контрагент) КАК ВзаиморасчетыОстатки
		|ГДЕ
		|	ВзаиморасчетыОстатки.Контрагент = &Контрагент
		|	И ВзаиморасчетыОстатки.СуммаВРубляхОстаток > 0
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Валюта
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	втДолгиПоПроектам.Контрагент КАК Контрагент,
		|	втДолгиПоПроектам.Проект КАК Проект,
		|	втДолгиПоПроектам.Валюта КАК Валюта,
		|	втДолгиПоПроектам.СуммаВРубляхОстаток КАК СуммаВРубляхОстаток,
		|	втДолгиПоПроектам.СуммаВВалютеОстаток КАК СуммаВВалютеОстаток,
		|	ВЫБОР
		|		КОГДА втДолгиПоПроектам.Валюта = ЗНАЧЕНИЕ(Справочник.Валюты.РоссийскийРубль)
		|			ТОГДА 1
		|		ИНАЧЕ ЕСТЬNULL(КурсыВалютСрезПоследних.Курс, ""НЕТ"")
		|	КОНЕЦ КАК Курс
		|ИЗ
		|	втДолгиПоПроектам КАК втДолгиПоПроектам
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.КурсыВалют.СрезПоследних(
		|				&Период,
		|				валюта В
		|					(ВЫБРАТЬ
		|						втДолгиПоПроектам.Валюта КАК Валюта
		|					ИЗ
		|						втДолгиПоПроектам КАК втДолгиПоПроектам)) КАК КурсыВалютСрезПоследних
		|		ПО втДолгиПоПроектам.Валюта = КурсыВалютСрезПоследних.Валюта";
	
	Запрос.УстановитьПараметр("Контрагент", Контрагент);
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени());
	Запрос.УстановитьПараметр("период", Дата);

	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	Списать = СуммаПоДокументу;	
	Пока Выборка.Следующий() И Списать > 0 Цикл 
		ТекСумма = Мин(Списать, Выборка.СуммаВРубляхОстаток);
		Если Выборка.Курс = "НЕТ" Тогда
			 Отказ = Истина;
			 Сообщить("Курс не заполнен");
		КонецЕсли;
		Если ТекСумма = Выборка.СуммаВРубляхОстаток Тогда
			СуммаВВалюте = Выборка.СуммаВВалютеОстаток;
		Иначе
			СуммаВВалюте = (Списать - ТекСумма) / Выборка.Курс;
		КонецЕсли;
		//контроль, если списывам 0,01Руб то в $ это будет ноль
		Если СуммаВВалюте > 0 Тогда
			Движение = Движения.Взаиморасчеты.ДобавитьРасход();
			Движение.период = Дата;
			Движение.Контрагент = Контрагент;
			Движение.проект = ВЫборка.Проект;
			Движение.Валюта = Выборка.Валюта;
			Движение.СуммаВРублях = ТекСумма;
			Движение.СуммаВВалюте = СуммаВВалюте;
	        Списать = Списать - ТекСумма;
		КонецЕсли;
		
	КонецЦикла;
	Если Списать > 0 Тогда
	    Движение = Движения.Взаиморасчеты.ДобавитьПриход();
		Движение.период = Дата;
		Движение.Контрагент = Контрагент;
		Движение.проект = Справочники.Проекты.ПустаяСсылка();
		Движение.Валюта = Справочники.Валюты.РоссийскийРубль;
		Движение.СуммаВРублях = Списать;
		Движение.СуммаВВалюте = Списать;
	КонецЕсли;
КонецПроцедуры
