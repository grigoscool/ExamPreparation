Функция ПолучитьВалюту(Проект) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Проекты.Валюта КАК Валюта
		|ИЗ
		|	Справочник.Проекты КАК Проекты
		|ГДЕ
		|	Проекты.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Проект);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Выборка.Следующий();

	Возврат Выборка.Валюта;
	
КонецФункции // ()
