import 'package:Gourmet2Go/src/models/dispatchmethod.dart';

class PreorderData {
  int selectedSlotTabIndex;
  int selectedSlotCellIndex;
  String day, time, info;
  PreorderData(this.selectedSlotTabIndex, this.selectedSlotCellIndex, this.day, this.time, this.info);
}

class AppData {
  String orderType = null, orderNote = null;
  PreorderData preorderData = null;
  DispatchMethod dispatchMethod = DispatchMethod.none;

  clone() {
    var n = AppData();
    n.orderType = this.orderType;
    n.orderNote = this.orderNote;
    n.dispatchMethod = this.dispatchMethod;
    n.preorderData = preorderData == null ? null : PreorderData(preorderData.selectedSlotTabIndex, preorderData.selectedSlotCellIndex, preorderData.day, preorderData.time, preorderData.info);
    return n;
  }

  copyFrom(AppData appdata) {
    this.orderNote = appdata.orderNote;
    this.orderType = appdata.orderType;
    this.dispatchMethod = appdata.dispatchMethod;
    this.preorderData = appdata.preorderData;
  }

  clear() {
    this.orderNote = null;
    this.orderType = null;
    this.preorderData = null;
    this.dispatchMethod = DispatchMethod.none;
  }

  writeToConsole() {
    print('orderNote -> ${this.orderNote}');
    print('orderType -> ${this.orderType}');
    print('preorderData -> tab : ${preorderData.selectedSlotTabIndex}, cell : ${preorderData.selectedSlotCellIndex}, day : ${preorderData.day}');

  }

}

final appData = new AppData();