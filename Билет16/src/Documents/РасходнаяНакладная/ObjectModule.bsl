
Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	СуммаПоДокументу = СписокНоменклатуры.Итог("Сумма");
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	//старая метода из-за блокировки
	Движения.Взаиморасчеты.Записывать = Истина;
	Движения.Записать();
	Движения.Взаиморасчеты.Записывать = Истина;
	
	//Блокировкад  
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрНакопления.Взаиморасчеты");
	ЭлементБлокировки.УстановитьЗначение("Контрагент", Контрагент);
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	Блокировка.Заблокировать();
	//два запроса 1-для суммы долга(остаток) 2-для получения суммы и срока кредита
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЕСТЬNULL(УсловияКредитаСрезПоследних.СуммаКредита, 0) КАК СуммаКредита,
	|	ЕСТЬNULL(УсловияКредитаСрезПоследних.СрокКредитаВДнях, 0) КАК СрокКредитаВДнях
	|ИЗ
	|	РегистрСведений.УсловияКредита.СрезПоследних(&МоментВремени, Контрагент = &Контрагент) КАК УсловияКредитаСрезПоследних
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЕСТЬNULL(СУММА(ВзаиморасчетыОстатки.СуммаДолгаОстаток),0) КАК СуммаДолга,
	|	ЕСТЬNULL(МИНИМУМ(ВзаиморасчетыОстатки.Накладная.Дата), Датавремя(1,1,1)) КАК НачалоКредита
	|ИЗ
	|	РегистрНакопления.Взаиморасчеты.Остатки(&МоментВремени, Контрагент = &Контрагент) КАК ВзаиморасчетыОстатки";
	
	Запрос.УстановитьПараметр("Контрагент", Контрагент);
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени());
	
	РезультатЗапросаМассив = Запрос.ВыполнитьПакет();
	
	ВыборкаКредит = РезультатЗапросаМассив[0].Выбрать();
	
	ВыборкаКредит.Следующий();
	
	Выборка = РезультатЗапросаМассив[1].Выбрать();
	Выборка.Следующий();  
	Если ВыборкаКредит.СуммаКредита = 0 ИЛИ ВыборкаКредит.СрокКредитаВДнях = 0 Тогда
		Отказ = Истина;
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не назначены условия кредита для контрагента";
		Сообщение.Сообщить();
	КонецЕсли;
	//если есть запись сравниваем иначе ругаемся
	Если ЗначениеЗаполнено(ВыборкаКредит.СуммаКредита) Тогда
		Если ВыборкаКредит.СуммаКредита < Выборка.СуммаДолга + СуммаПоДокументу Тогда
			Отказ = Истина;
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = "Превышен лимит кредита";
			Сообщение.Сообщить();	  
		КонецЕсли; 
	Иначе
		Отказ = Истина;
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не назначены условия кредита для контрагента";
		Сообщение.Сообщить();
	КонецЕсли;
	//если есть дата выдачи кредита сравниваем
	Если ЗначениеЗаполнено(Выборка.НачалоКредита) Тогда
		Если Выборка.НачалоКредита + ВыборкаКредит.СрокКредитаВДнях *24 * 60 *60 < Дата Тогда
			Отказ = Истина;
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = "Превышен срок кредита";
			Сообщение.Сообщить();	  
		КонецЕсли; 	
	КонецЕсли;
    //если прошли все проверки - проводим
	Движение = Движения.Взаиморасчеты.ДобавитьПриход();
	Движение.Период = Дата;
	Движение.Контрагент = Контрагент;
	Движение.Накладная = Ссылка;
	Движение.СуммаДолга = СуммаПоДокументу;
КонецПроцедуры
