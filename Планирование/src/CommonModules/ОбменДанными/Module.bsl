Процедура ПрочитатьДанные() Экспорт

	ТабДок = Новый ТабличныйДокумент;
	ТабДок.Прочитать("\\SERVER1C1\D$\DontTuch\graf.mxl");
	ОбработатьДанные(ТабДок, Истина);

	ТабДок.Прочитать("\\SERVER1C1\D$\DontTuch\graf_plus.mxl");
	ОбработатьДанные(ТабДок, Ложь);

КонецПроцедуры

Процедура ОбработатьДанные(ТабДок, Продажи = Неопределено)
	Для ТекСтрока = 1 По ТабДок.ВысотаТаблицы Цикл
		Если Продажи Тогда
			Период = Дата(ТабДок.Область(ТекСтрока, 1, ТекСтрока, 1).Текст);
			ПартнерКод = ТабДок.Область(ТекСтрока, 2, ТекСтрока, 2).Текст;
			кол = ТабДок.Область(ТекСтрока, 6, ТекСтрока, 6).Текст;
			Если кол = "" Тогда
				Продолжить;
			Иначе
				Количество = число(СтрЗаменить(кол, " ", ""));
			КонецЕсли;
			Клиент = Справочники.Партнеры.НайтиПоКоду(ПартнерКод);
			Выручка = ТабДок.Область(ТекСтрока, 9, ТекСтрока, 9).Текст;
		КонецЕсли;
		Если Клиент = ПредопределенноеЗначение("Справочник.Партнеры.ПустаяСсылка") Тогда
			ПартнерНаименование = ТабДок.Область(ТекСтрока, 3, ТекСтрока, 3).Текст;
			ПартнерОбъект = Справочники.Партнеры.СоздатьЭлемент();
			ПартнерОбъект.Код = ПартнерКод;
			ПартнерОбъект.Наименование = ПартнерНаименование;
			ПартнерОбъект.Записать();
			Клиент = ПартнерОбъект.Ссылка;
		КонецЕсли;
		НоменклатураКод = ТабДок.Область(ТекСтрока, 4, ТекСтрока, 4).Текст;
		Номенклатура = Справочники.Номенклатура.НайтиПоКоду(НоменклатураКод);
		Брэнд = ТабДок.Область(ТекСтрока, 7, ТекСтрока, 7).Текст;
		Автопланирование = булево(число(ТабДок.Область(ТекСтрока, 8, ТекСтрока, 8).Текст));
		Если Номенклатура = ПредопределенноеЗначение("Справочник.Номенклатура.ПустаяСсылка") Тогда
			НоменклатураНаименование = ТабДок.Область(ТекСтрока, 5, ТекСтрока, 5).Текст;
			НоменклатураОбъект = Справочники.Номенклатура.СоздатьЭлемент();
			НоменклатураОбъект.Код = НоменклатураКод;
			НоменклатураОбъект.Наименование = НоменклатураНаименование;
			НоменклатураОбъект.Родитель = ВернутьРодителя(Брэнд);
			НоменклатураОбъект.Записать();
			Номенклатура = НоменклатураОбъект.Ссылка;
		ИначеЕсли Номенклатура.Родитель.Наименование <> Брэнд Тогда
			НоменклатураОбъект = Номенклатура.ПолучитьОбъект();
			НоменклатураОбъект.Родитель = ВернутьРодителя(Брэнд);
			НоменклатураОбъект.Записать();
		ИначеЕсли Номенклатура.Автопланирование <> Брэнд Тогда
			НоменклатураОбъект = Номенклатура.ПолучитьОбъект();
			НоменклатураОбъект.Автопланирование = Автопланирование;
			НоменклатураОбъект.Записать();
		КонецЕсли;

		Если Продажи Тогда
			НоваяЗапись = РегистрыСведений.ДанныеПродаж.СоздатьМенеджерЗаписи();
			НоваяЗапись.Период 			= Период;
			НоваяЗапись.Номенклатура 	= Номенклатура;
			НоваяЗапись.Клиент 			= Клиент;
			НоваяЗапись.Количество 		= Количество;
			НоваяЗапись.Выручка 		= Число(СтрЗаменить(Выручка, " ", ""));
			НоваяЗапись.Записать(Истина);
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

Функция ВернутьРодителя(Брэнд)

	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Номенклатура.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.Номенклатура КАК Номенклатура
	|ГДЕ
	|	Номенклатура.Наименование = &Наименование
	|	И Номенклатура.ЭтоГруппа";

	Запрос.УстановитьПараметр("Наименование", Брэнд);

	РезультатЗапроса = Запрос.Выполнить();

	Выборка = РезультатЗапроса.Выбрать();

	Пока Выборка.Следующий() Цикл
		Возврат Выборка.Ссылка;
	КонецЦикла;

	ГруппаОбъект = Справочники.Номенклатура.СоздатьГруппу();
	ГруппаОбъект.Наименование = Брэнд;
	ГруппаОбъект.Записать();

	Возврат ГруппаОбъект.Ссылка;

КонецФункции

Функция ПолучитьДанныеСезонныхКоэффициентов(ГруппаСезонности) Экспорт

	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	НАЧАЛОПЕРИОДА(ДанныеПродаж.Период, МЕСЯЦ) КАК Период,
	|	СУММА(ДанныеПродаж.Количество) КАК Количество,
	|	ДанныеПродаж.Номенклатура КАК Номенклатура
	|ПОМЕСТИТЬ вт
	|ИЗ
	|	РегистрСведений.ДанныеПродаж КАК ДанныеПродаж
	|ГДЕ
	|	ДанныеПродаж.Номенклатура.ГруппаСезонности = &ГруппаСезонности
	|	И ДанныеПродаж.Период >= &ДатаНачала
	|	И ДанныеПродаж.Период <= &ДатаОкончания
	|
	|СГРУППИРОВАТЬ ПО
	|	ДанныеПродаж.Номенклатура,
	|	НАЧАЛОПЕРИОДА(ДанныеПродаж.Период, МЕСЯЦ)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	вт.Период КАК Месяц,
	|	СРЕДНЕЕ(вт.Количество / ВложенныйЗапрос.ОбщееКоличество * ВложенныйЗапрос.КолПериодов) КАК Коэффициент
	|ИЗ
	|	(ВЫБРАТЬ
	|		СУММА(вт.Количество) КАК ОбщееКоличество,
	|		вт.Номенклатура КАК Номенклатура,
	|		КОЛИЧЕСТВО(РАЗЛИЧНЫЕ вт.Период) КАК КолПериодов
	|	ИЗ
	|		вт КАК вт
	|	
	|	СГРУППИРОВАТЬ ПО
	|		вт.Номенклатура) КАК ВложенныйЗапрос
	|		ЛЕВОЕ СОЕДИНЕНИЕ вт КАК вт
	|		ПО (вт.Номенклатура = ВложенныйЗапрос.Номенклатура)
	|
	|СГРУППИРОВАТЬ ПО
	|	вт.Период
	|
	|УПОРЯДОЧИТЬ ПО
	|	Месяц
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	вт.Номенклатура КАК Номенклатура,
	|	СУММА(вт.Количество) КАК Количество,
	|	вт.Период КАК Период
	|ИЗ
	|	вт КАК вт
	|
	|СГРУППИРОВАТЬ ПО
	|	вт.Номенклатура,
	|	вт.Период
	|
	|УПОРЯДОЧИТЬ ПО
	|	Период
	|ИТОГИ ПО
	|	Номенклатура";

	Запрос.УстановитьПараметр("ГруппаСезонности", ГруппаСезонности);
	ВыбПериод = Новый СтандартныйПериод;
	ВыбПериод.Вариант = ВариантСтандартногоПериода.ПрошлыйГод;
	Запрос.УстановитьПараметр("ДатаНачала", ВыбПериод.ДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкончания", ВыбПериод.ДатаОкончания);

	Результат = Запрос.ВыполнитьПакет();

	ВыборкаНоменклатура = Результат[2].Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаНоменклатура.Следующий() Цикл
		МассивДанных = Новый Массив;
		Выборка = ВыборкаНоменклатура.Выбрать();
		Пока Выборка.Следующий() Цикл
			МассивДанных.Добавить(Выборка.Количество);
		КонецЦикла;
		//КоэфТр = КоэффициентыТренда(МассивДанных);
		//ЗаписатьКоэффициенты(КоэфТр, ВыборкаНоменклатура.Номенклатура, ВыбПериод.ДатаНачала);
	КонецЦикла;

	Возврат Результат[1];

КонецФункции

Функция ПолучитьДанныеСезонныхКоэффициентовСкользящих(СтруктураПараметров) Экспорт

	Схема = Обработки.Сглаживание.ПолучитьМакет("Макет");

	ПериодСреднейДни = Константы.ПериодСкользящей.Получить();
	СтрокаВыражения = Схема.ПоляИтога.Найти("Среднее").Выражение;
	СтрокаВыражения = СтрЗаменить(СтрокаВыражения, "30", Формат(ПериодСреднейДни, "ЧДЦ=0; ЧГ=0"));
	СтрокаВыражения = СтрЗаменить(СтрокаВыражения, "31", Формат(ПериодСреднейДни + 1, "ЧДЦ=0; ЧГ=0"));
	Схема.ПоляИтога.Найти("Среднее").Выражение = СтрокаВыражения;

	Настройки = Схема.НастройкиПоУмолчанию;
	Если СтруктураПараметров.Свойство("Номенклатура") Тогда
		СерверныеФункции.ДобавитьОтборСКД("Номенклатура", Настройки, 
		ВидСравненияКомпоновкиДанных.Равно, СтруктураПараметров.Номенклатура);   
	Иначе
		СерверныеФункции.ДобавитьОтборСКД("Номенклатура.ГруппаСезонности", Настройки, 
		ВидСравненияКомпоновкиДанных.Равно, СтруктураПараметров.ГруппаСезонности); 
	КонецЕсли;
	ВыбПериод = Новый СтандартныйПериод;
	ВыбПериод.Вариант = ВариантСтандартногоПериода.ПрошлыйГод;
	
	СерверныеФункции.УстановитьПараметрСКД("Период", Настройки, ВидСравнения, ВыбПериод);
		
	тз = Новый ТаблицаЗначений;	
	СерверныеФункции.ВывестиВКоллекциюЗначений(Схема, Настройки, тз);

	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ВЫРАЗИТЬ(тз.Период КАК ДАТА) КАК Период,
	|	тз.Номенклатура КАК Номенклатура,
	|	тз.Количество КАК Количество,
	|	тз.Среднее КАК Среднее
	|ПОМЕСТИТЬ вт
	|ИЗ
	|	&тз КАК тз
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ ПЕРВЫЕ 0
	|	вт.Период КАК Период,
	|	вт.Номенклатура КАК Номенклатура,
	|	вт.Количество КАК Количество
	|ИЗ
	|	вт КАК вт
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	НАЧАЛОПЕРИОДА(ДОБАВИТЬКДАТЕ(вт.Период, ДЕНЬ, &Сдвиг), МЕСЯЦ) КАК Период,
	|	СУММА(ЕСТЬNULL(вт.Среднее, 0)) КАК Количество,
	|	вт.Номенклатура КАК Номенклатура
	|ИЗ
	|	вт КАК вт
	|ГДЕ
	|	НАЧАЛОПЕРИОДА(ДОБАВИТЬКДАТЕ(вт.Период, ДЕНЬ, &Сдвиг), МЕСЯЦ) >= &ДатаНачала
	|	И НАЧАЛОПЕРИОДА(ДОБАВИТЬКДАТЕ(вт.Период, ДЕНЬ, &Сдвиг), МЕСЯЦ) <= &ДатаОкончания
	|
	|СГРУППИРОВАТЬ ПО
	|	НАЧАЛОПЕРИОДА(ДОБАВИТЬКДАТЕ(вт.Период, ДЕНЬ, &Сдвиг), МЕСЯЦ),
	|	вт.Номенклатура
	|
	|УПОРЯДОЧИТЬ ПО
	|	Период
	|ИТОГИ ПО
	|	Номенклатура";
	//|;
	//|
	//|////////////////////////////////////////////////////////////////////////////////
	//|ВЫБРАТЬ
	//|	вт2.Период КАК Месяц,
	//|	СРЕДНЕЕ(вт2.Количество / ВложенныйЗапрос.ОбщееКоличество * 12) КАК Коэффициент
	//|ИЗ
	//|	(ВЫБРАТЬ
	//|		СУММА(вт2.Количество) КАК ОбщееКоличество,
	//|		вт2.Номенклатура КАК Номенклатура
	//|	ИЗ
	//|		вт2 КАК вт2
	//|	
	//|	СГРУППИРОВАТЬ ПО
	//|		вт2.Номенклатура) КАК ВложенныйЗапрос
	//|		ЛЕВОЕ СОЕДИНЕНИЕ вт2 КАК вт2
	//|		ПО (вт2.Номенклатура = ВложенныйЗапрос.Номенклатура)
	//|
	//|СГРУППИРОВАТЬ ПО
	//|	вт2.Период
	//|
	//|УПОРЯДОЧИТЬ ПО
	//|	Месяц";
	
	//Если Данные = 1 Тогда
	//	Запрос.Текст = СтрЗаменить(Запрос.Текст, "НЕДЕЛЯ", "МЕСЯЦ");
	//КонецЕсли;

	Запрос.УстановитьПараметр("ДатаНачала", ВыбПериод.ДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкончания", ВыбПериод.ДатаОкончания);
	Запрос.УстановитьПараметр("тз", тз);
	Сдвиг = -Цел(ПериодСреднейДни / 2);
	Запрос.УстановитьПараметр("Сдвиг", Сдвиг);

	Результат = Запрос.ВыполнитьПакет();

	тд = Результат[1].Выгрузить();
	
	ВыборкаНоменклатура = Результат[2].Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаНоменклатура.Следующий() Цикл
		МассивДанных = Новый Массив;
		Выборка = ВыборкаНоменклатура.Выбрать();
		БылиПродажи = Ложь;
		Пока Выборка.Следующий() Цикл
			Количество = Выборка.Количество;
			Если Не БылиПродажи И Количество Тогда
				БылиПродажи = Истина;	
			КонецЕсли;
			Если БылиПродажи Тогда
				МассивДанных.Добавить(Выборка.Количество);
				НовСтр = тд.Добавить();
				ЗаполнитьЗначенияСвойств(НовСтр, Выборка);
			КонецЕсли;
		КонецЦикла;
		//Если МассивДанных.Количество() Тогда
		//	КоэфТр = КоэффициентыТренда(МассивДанных);		
		//	ЗаписатьКоэффициенты(КоэфТр, ВыборкаНоменклатура.Номенклатура, ВыбПериод.ДатаНачала);
		//КонецЕсли;
	КонецЦикла;
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ВЫРАЗИТЬ(тз.Период КАК ДАТА) КАК Период,
	|	тз.Номенклатура КАК Номенклатура,
	|	тз.Количество КАК Количество
	|ПОМЕСТИТЬ вт2
	|ИЗ
	|	&тз КАК тз
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	вт2.Период КАК Месяц,
	|	ВЫБОР
	|		КОГДА ВложенныйЗапрос.ОбщееКоличество = 0
	|			ТОГДА 0
	|		ИНАЧЕ вт2.Количество / ВложенныйЗапрос.ОбщееКоличество * ВложенныйЗапрос.КоличествоПериодов
	|	КОНЕЦ КАК Коэффициент
	|ИЗ
	|	(ВЫБРАТЬ
	|		СУММА(ЕСТЬNULL(вт2.Количество, 0)) КАК ОбщееКоличество,
	|		вт2.Номенклатура КАК Номенклатура,
	|		КОЛИЧЕСТВО(РАЗЛИЧНЫЕ вт2.Период) КАК КоличествоПериодов
	|	ИЗ
	|		вт2 КАК вт2
	|	
	|	СГРУППИРОВАТЬ ПО
	|		вт2.Номенклатура) КАК ВложенныйЗапрос
	|		ЛЕВОЕ СОЕДИНЕНИЕ вт2 КАК вт2
	|		ПО (вт2.Номенклатура = ВложенныйЗапрос.Номенклатура)
	|
	|СГРУППИРОВАТЬ ПО
	|	вт2.Период,
	|	ВЫБОР
	|		КОГДА ВложенныйЗапрос.ОбщееКоличество = 0
	|			ТОГДА 0
	|		ИНАЧЕ вт2.Количество / ВложенныйЗапрос.ОбщееКоличество * ВложенныйЗапрос.КоличествоПериодов
	|	КОНЕЦ
	|
	|УПОРЯДОЧИТЬ ПО
	|	Месяц";
	Запрос.УстановитьПараметр("тз", тд);
	Результат = Запрос.Выполнить();

	Возврат Результат;

КонецФункции

Процедура ЗаписатьКоэффициенты(КоэфТр, Номенклатура, Период, Клиент = Неопределено)
	НоваяЗапись = РегистрыСведений.ЛинейныйТренд.СоздатьМенеджерЗаписи();
	НоваяЗапись.Период = Период;
	НоваяЗапись.a = КоэфТр.a;
	НоваяЗапись.b = КоэфТр.b;
	НоваяЗапись.Порядок = КоэфТр.Порядок;
	НоваяЗапись.Номенклатура = Номенклатура;
	Если типзнч(Клиент) = тип("СправочникСсылка.Партнеры") Тогда
		НоваяЗапись.Клиент = Клиент;
	КонецЕсли;
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
Функция КоэффициентыТренда(Данные) Экспорт
	
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

