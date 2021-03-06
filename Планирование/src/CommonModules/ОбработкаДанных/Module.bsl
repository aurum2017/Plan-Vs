Процедура ПолучитьГодовыеЛинейныеТренды(СтруктураПараметров = Неопределено, ПериодСкользСредней = 0, Сглаживать = Истина) Экспорт
	
	ВыбПериод = Новый СтандартныйПериод;
	ВыбПериод.Вариант = ВариантСтандартногоПериода.ПрошлыйГод;
	Запрос = Новый Запрос;
	тз = Новый ТаблицаЗначений;
		
	Если Сглаживать Тогда
		Схема = ПолучитьОбщийМакет("СкользящиеСредние");
		Если ПериодСкользСредней = 0 Тогда
			ПериодСкользСредней = Константы.ПериодСкользящей.Получить();
		КонецЕсли;
		СтрокаВыражения = Схема.ПоляИтога.Найти("Среднее").Выражение;
		СтрокаВыражения = СтрЗаменить(СтрокаВыражения, "30", Формат(ПериодСкользСредней, "ЧДЦ=0; ЧГ=0"));
		СтрокаВыражения = СтрЗаменить(СтрокаВыражения, "31", Формат(ПериодСкользСредней + 1, "ЧДЦ=0; ЧГ=0"));
		Схема.ПоляИтога.Найти("Среднее").Выражение = СтрокаВыражения;
		
		Настройки = Схема.НастройкиПоУмолчанию;
		Если СтруктураПараметров <> Неопределено тогда
			Если СтруктураПараметров.Свойство("Номенклатура") Тогда
				СерверныеФункции.ДобавитьОтборСКД("Номенклатура", Настройки, 
				ВидСравненияКомпоновкиДанных.Равно, СтруктураПараметров.Номенклатура);   
			ИначеЕсли СтруктураПараметров.Свойство("ГруппаСезонности") Тогда
				СерверныеФункции.ДобавитьОтборСКД("Номенклатура.ГруппаСезонности", Настройки, 
				ВидСравненияКомпоновкиДанных.Равно, СтруктураПараметров.ГруппаСезонности); 
			КонецЕсли;
		КонецЕсли;
		
		СерверныеФункции.УстановитьПараметрСКД("Период", Настройки, ВидСравнения, ВыбПериод);	
		СерверныеФункции.ВывестиВКоллекциюЗначений(Схема, Настройки, тз);
		Запрос.Текст = ТекстыЗапросов.ОпределениеКоэффициентовТренда();
	Иначе
		Запрос.Текст = ТекстыЗапросов.ПомесячныеДанныеПродаж();
	КонецЕсли;
		
	Запрос.УстановитьПараметр("ДатаНачала", ВыбПериод.ДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкончания", ВыбПериод.ДатаОкончания);
	Запрос.УстановитьПараметр("тз", тз);
	Сдвиг = -Цел(ПериодСкользСредней / 2);
	Запрос.УстановитьПараметр("Сдвиг", Сдвиг);
	
	Результат = Запрос.Выполнить();
	ВыборкаНоменклатура = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаНоменклатура.Следующий() Цикл
		ВыборкаКлиент = ВыборкаНоменклатура.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);	
		Пока ВыборкаКлиент.Следующий() Цикл	
			//ВыборкаПериод = ВыборкаКлиент.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "Период", "ВСЕ");	
			//Пока ВыборкаПериод.Следующий() Цикл	
				МассивДанных = Новый Массив;
				Выборка = ВыборкаКлиент.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "Период", "ВСЕ");
				БылиПродажи = Ложь;
				ПоследнийПериод = Дата(1,1,1);
				Пока Выборка.Следующий() Цикл
					Количество = ?(Выборка.Количество = null, 0, Выборка.Количество);
					Если Количество Тогда
						Если Не БылиПродажи Тогда
							БылиПродажи = Истина;	
						КонецЕсли;
						ПоследнийПериод = Выборка.Период;
					КонецЕсли;
					Если БылиПродажи Тогда
						МассивДанных.Добавить(Количество);
					КонецЕсли;                                             
				КонецЦикла;
				СерверныеФункции.УбартьПоследнииеНули(МассивДанных);
				Если МассивДанных.Количество() Тогда
					КоэфТр = ПолучитьКоэффициентыТренда(МассивДанных);	   
					Если КоэфТр.a = КоэфТр.b = 0  Тогда
						ЗаписатьКоэффициенты(КоэфТр, ВыборкаНоменклатура.Номенклатура, ВыбПериод.ДатаНачала, ВыборкаКлиент.Клиент, Сглаживать, ПоследнийПериод);
					КонецЕсли;
				КонецЕсли;
			//КонецЦикла;	
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры



Процедура ЗаписатьКоэффициенты(КоэфТр, Номенклатура, Период, Клиент = Неопределено, Сглаживать, ПоследнийПериод)
	НоваяЗапись = РегистрыСведений.ЛинейныйТренд.СоздатьМенеджерЗаписи();
	НоваяЗапись.Период = Период;
	НоваяЗапись.a = КоэфТр.a;
	НоваяЗапись.b = КоэфТр.b;
	НоваяЗапись.Порядок = КоэфТр.Порядок;
	НоваяЗапись.Номенклатура = Номенклатура;
	НоваяЗапись.Клиент = Клиент;
	НоваяЗапись.СглаженныеДанные = Сглаживать;
	НоваяЗапись.LastSale = ПоследнийПериод;
	НоваяЗапись.Записать(Истина);
КонецПроцедуры

// Коэффициенты тренда.
// 
// Параметры:
//  Данные - Массив - Данные
// 
// Возвращаемое значение:
//  Структура - Коэффициенты тренда Y = aX+b:
// * a - Число -
// * b - Число -
// * Порядок - Число - Последний Х продаж
Функция ПолучитьКоэффициентыТренда(Данные)
	
	//ToDo: "Bonsai  Professional" Cоус соевий класичний 1000 мл. (концентрат 1:1 ) ПЕТ
	 //когда количество периодов в продажах меньше года коэф неправильные
	Если Данные.Количество() < 2 Тогда
		КоэффициентыУравнения = Новый Структура("a,b", 0, 0);
		Возврат КоэффициентыУравнения;
	КонецЕсли;
	Н = Данные.Количество();
	СумХУ = 0.0;
	СумХ = 0.0;
	СумУ = 0.0;
	СумХ2 = 0.0;

	Для к = 1 По Н Цикл
		СумХУ = СумХУ + к * Данные[к - 1];
		СумХ = СумХ + к;
		СумУ = СумУ + Данные[к - 1];
		СумХ2 = СумХ2 + к * к;
	КонецЦикла;

	a = (СумХУ - СумХ * СумУ / Н) / (СумХ2 - СумХ * СумХ / Н);
	b = (СумУ - a * СумХ) / Н;

	КоэффициентыУравнения = Новый Структура("a,b,Порядок", a, b, Н);
	
	Возврат КоэффициентыУравнения;
	
КонецФункции