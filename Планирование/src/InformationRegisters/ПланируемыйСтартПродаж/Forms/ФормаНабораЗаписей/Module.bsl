&НаКлиенте
Процедура НаборЗаписейПередОкончаниемРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования, Отказ)
	Элемент.ТекущиеДанные.Номенклатура = ПолучитьНоменклатуру();
КонецПроцедуры

&НаСервере
Функция ПолучитьНоменклатуру()
	Возврат НаборЗаписей.Отбор.Номенклатура.Значение;
КонецФункции