
Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	СуммаПоДокументу = СписокНоменклатуры.Итог("Сумма");
	
КонецПроцедуры

Процедура ОбработкаПроведенияОУ(Отказ, РежимПроведения)
	Движения.ОстаткиНоменклатуры.Записывать = Истина;
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПриходнаяНакладнаяСписокНоменклатуры.Номенклатура КАК Номенклатура,
		|	СУММА(ПриходнаяНакладнаяСписокНоменклатуры.Количество) КАК Количество,
		|	СУММА(ПриходнаяНакладнаяСписокНоменклатуры.Сумма) КАК Сумма
		|ИЗ
		|	Документ.ПриходнаяНакладная.СписокНоменклатуры КАК ПриходнаяНакладнаяСписокНоменклатуры
		|ГДЕ
		|	ПриходнаяНакладнаяСписокНоменклатуры.Ссылка = &Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	ПриходнаяНакладнаяСписокНоменклатуры.Номенклатура";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Движение = Движения.ОстаткиНоменклатуры.ДобавитьПриход();
		Движение.Период = Дата;
		Движение.Номенклатура = Выборка.Номенклатура;
		Движение.Партия = Ссылка;
		Движение.Количество = Выборка.Количество;
		Движение.Себестоимость = Выборка.Сумма;
	КонецЦикла;
	
КонецПроцедуры

Процедура ОбработкаПроведенияБУ(Отказ, Режим)

	//// регистр Управленческий 
	//Движения.Управленческий.Записывать = Истина;
	//Для Каждого ТекСтрокаСписокНоменклатуры Из СписокНоменклатуры Цикл
	//	Движение = Движения.Управленческий.Добавить();
	//	Движение.СчетДт = ПланыСчетов.Управленческий.Товары;
	//	Движение.СчетКт = ПланыСчетов.Управленческий.Поставщики;
	//	Движение.Период = Дата;
	//	Движение.Сумма = ТекСтрокаСписокНоменклатуры.Сумма;
	//	Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Номенклатура] = ТекСтрокаСписокНоменклатуры.Номенклатура;
	//	Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Склады] = ТекСтрокаСписокНоменклатуры.Склад;
	//	Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Партии] = Ссылка;
	//КонецЦикла;  
	//
	
	Движения.Управленческий.Записывать = Истина;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПриходнаяНакладнаяСписокНоменклатуры.Номенклатура КАК Номенклатура,
		|	ПриходнаяНакладнаяСписокНоменклатуры.Склад КАК Склад,
		|	СУММА(ПриходнаяНакладнаяСписокНоменклатуры.Сумма) КАК Сумма,
		|	СУММА(ПриходнаяНакладнаяСписокНоменклатуры.Количество) КАК Количество
		|ИЗ
		|	Документ.ПриходнаяНакладная.СписокНоменклатуры КАК ПриходнаяНакладнаяСписокНоменклатуры
		|ГДЕ
		|	ПриходнаяНакладнаяСписокНоменклатуры.Ссылка = &Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	ПриходнаяНакладнаяСписокНоменклатуры.Номенклатура,
		|	ПриходнаяНакладнаяСписокНоменклатуры.Склад";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		 Движение = Движения.Управленческий.Добавить();
		 Движение.Период = Дата;
		 Движение.СчетДт = ПланыСчетов.Управленческий.Товары;
		 Движение.СчетКт = ПланыСчетов.Управленческий.Поставщики;
		 Движение.СубконтоДт.Номенклатура = Выборка.Номенклатура;
		 Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконто.Склады] = Выборка.Склад;
		 Движение.СубконтоДт.Партии = Ссылка;
		 Движение.КоличествоДт = Выборка.Количество;
		 Движение.Сумма = Выборка.Сумма;
	КонецЦикла;
	
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	ОбработкаПроведенияОУ(Отказ, РежимПроведения);
	ОбработкаПроведенияБУ(Отказ, РежимПроведения);
КонецПроцедуры
