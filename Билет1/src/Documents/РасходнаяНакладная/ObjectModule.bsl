
Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	СуммаПоДокументу = СписокНоменклатуры.Итог("Сумма");
	
КонецПроцедуры



Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	//Находим текущий метод списания себестоимости
	МетодРС = РегистрыСведений.МетодыРасчетнойПолитики.ПолучитьПоследнее(Дата).МетодРС;
	Если НЕ ЗначениеЗаполнено(МетодРС) Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не занпол уч пол";
		Сообщение.Сообщить();
	КонецЕсли;	
	//Новая метода списание остатков
	//узнаем из ТЧ РасходнойНакладной количество и наименование номенклатуры 
	МенеджерВТ = Новый МенеджерВременныхТаблиц();
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = МенеджерВТ;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура КАК Номенклатура,
		|	СУММА(РасходнаяНакладнаяСписокНоменклатуры.Количество) КАК Количество
		|ПОМЕСТИТЬ втТЧТовары
		|ИЗ
		|	Документ.РасходнаяНакладная.СписокНоменклатуры КАК РасходнаяНакладнаяСписокНоменклатуры
		|ГДЕ
		|	РасходнаяНакладнаяСписокНоменклатуры.Ссылка = &Ссылка
		|	И РасходнаяНакладнаяСписокНоменклатуры.Номенклатура.ВидНоменклатуры <> ЗНАЧЕНИЕ(Перечисление.ВидыНоменклатуры.Услуга)
		|СГРУППИРОВАТЬ ПО
		|	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Номенклатура
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	втТЧТовары.Номенклатура,
		|	втТЧТовары.Количество
		|ИЗ
		|	втТЧТовары КАК втТЧТовары";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	//расходуем что получили по РегиструНакопления ОстаткиНоменклатуры
	Пока Выборка.Следующий() Цикл
		Движение = Движения.ОстаткиНоменклатуры.ДобавитьРасход();
		Движение.Период = Дата;
		Движение.Номенклатура = Выборка.Номенклатура;
		Движение.Склад = Склад;
		Движение.Количество = Выборка.Количество;
	КонецЦикла;
	//Ставим управл блокировку и записываем данные в регистр 
	Движения.ОстаткиНоменклатуры.Записывать = Истина;
	Движения.ОстаткиНоменклатуры.БлокироватьДляИзменения = Истина;
	Движения.ОстаткиНоменклатуры.Записать();
	//проверяем после записи новых данных есть ли отрицательные остатки
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = МенеджерВТ;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ОстаткиНоменклатурыОстатки.Номенклатура.Представление КАК НоменклатураПредст,
		|	ОстаткиНоменклатурыОстатки.Склад.Представление КАК СкладПредст,
		|	ОстаткиНоменклатурыОстатки.КоличествоОстаток КАК КоличествоОстаток
		|ИЗ
		|	РегистрНакопления.ОстаткиНоменклатуры.Остатки(&Граница, Склад = &Склад
		|	И Номенклатура В
		|		(ВЫБРАТЬ
		|			Т.Номенклатура
		|		ИЗ
		|			втТЧТовары КАК Т)) КАК ОстаткиНоменклатурыОстатки
		|ГДЕ
		|	ОстаткиНоменклатурыОстатки.КоличествоОстаток < 0";
	
	Запрос.УстановитьПараметр("Склад", Склад);
	Запрос.УстановитьПараметр("Граница", Новый Граница(МоментВремени(), ВидГраницы.Включая));
	
	РезультатЗапроса = Запрос.Выполнить();
	Если НЕ РезультатЗапроса.Пустой() Тогда
		Выборка = РезультатЗапроса.Выбрать();
		Пока Выборка.Следующий() Цикл
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = СтрШаблон("Не хватает %1 на складе %2 в кол-ве %3шт.", 
										Выборка.НоменклатураПредст,
										Выборка.СкладПредст,
										-Выборка.КоличествоОстаток);
			Сообщение.Сообщить();							
		КонецЦикла;
		Отказ = Истина;
	КонецЕсли;
	
	//старая метода для списания себестоимости
	Движения.ОстаткиСебестоимости.Записывать = Истина;
	Движения.ОстаткиСебестоимости.Записать();
	Движения.ОстаткиСебестоимости.Записывать = Истина;
	//Блокировка ручная
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрНакопления.ОстаткиСебестоимости");
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	ЭлементБлокировки.ИсточникДанных = СписокНоменклатуры;
	ЭлементБлокировки.ИспользоватьИзИсточникаДанных("Номенклатура", "Номенклатура");
	Блокировка.Заблокировать();
	//Запрос для контроля остатков себестоимости в разрезе партий по FIFO/LIFO

	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = МенеджерВТ;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	втТЧТовары.Номенклатура КАК Номенклатура,
		|	втТЧТовары.Количество КАК Количество,
		|	ОстаткиСебестоимостиОстатки.Партия КАК Партия,
		|	ЕСТЬNULL(ОстаткиСебестоимостиОстатки.КоличествоОстаток, 0) КАК КоличествоОстаток,
		|	ЕСТЬNULL(ОстаткиСебестоимостиОстатки.СебестоимостьОстаток, 0) КАК СебестоимостьОстаток,
		|	втТЧТовары.Номенклатура.Представление КАК НоменклатураПредставление,
		|	втТЧТовары.Номенклатура.ВидНоменклатуры КАК ВидНоменклатуры
		|ИЗ
		|	втТЧТовары КАК втТЧТовары,
		|	РегистрНакопления.ОстаткиСебестоимости.Остатки(&МоментВремени, Номенклатура В
		|		(ВЫБРАТЬ
		|			Т.Номенклатура
		|		ИЗ
		|			втТЧТовары КАК Т)) КАК ОстаткиСебестоимостиОстатки
		|
		|УПОРЯДОЧИТЬ ПО
		|	ОстаткиСебестоимостиОстатки.Партия.МоментВремени УБЫВ
		|ИТОГИ
		|	МАКСИМУМ(Количество),
		|	СУММА(КоличествоОстаток),
		|	СУММА(СебестоимостьОстаток)
		|ПО
		|	Номенклатура";
	//меняем метод списания себестоимости в зависимости от принятого
	Если МетодРС = Перечисления.УчетнаяПолитика.ФИФО Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "УБЫВ", "");
	КонецЕсли;
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени());
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаНоменклатура = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Пока ВыборкаНоменклатура.Следующий() Цикл
		//если количество расходуемое больше остатков - отказ
		Если ВыборкаНоменклатура.Количество > ВыборкаНоменклатура.КоличествоОстаток Тогда
			Отказ = Истина;
			Сообщение = Новый СообщениеПользователю();
			Сообщение.Текст = СтрШаблон("Нехватает %1 в кол-ве %2", 
										ВыборкаНоменклатура.НоменклатураПредставление,
										ВыборкаНоменклатура.Количество - ВыборкаНоменклатура.КоличествоОстаток);
	
			
			Если Отказ Тогда
				Продолжить;
			КонецЕсли;
		КонецЕсли;
		//если меньше - движения
		КоличествоСписать = ВыборкаНоменклатура.Количество;
		Выборка = ВыборкаНоменклатура.Выбрать();	
		Пока Выборка.Следующий()  И КоличествоСписать > 0 Цикл
			ТекКоличество = Мин(КоличествоСписать, Выборка.КоличествоОстаток);
			Если ТекКоличество = ВыборкаНоменклатура.КоличествоОстаток Тогда
				Себестоимость = ВыборкаНоменклатура.СебестоимостьОстаток;
			Иначе
				Себестоимость = ТекКоличество / ВыборкаНоменклатура.КоличествоОстаток
											  * ВыборкаНоменклатура.СебестоимостьОстаток;
			КонецЕсли;
			Движение = Движения.ОстаткиСебестоимости.ДобавитьРасход();
			Движение.Период = Дата;
			Движение.Номенклатура = Выборка.Номенклатура;
			Движение.Партия = Выборка.Партия;
			Движение.Количество = ТекКоличество;
			Движение.Себестоимость = Себестоимость;
			КоличествоСписать = КоличествоСписать - ТекКоличество;
		КонецЦикла;
	КонецЦикла;

КонецПроцедуры



