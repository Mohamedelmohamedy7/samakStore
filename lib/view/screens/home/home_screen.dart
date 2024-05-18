import 'package:efood_multivendor_restaurant/controller/auth_controller.dart';
import 'package:efood_multivendor_restaurant/controller/notification_controller.dart';
import 'package:efood_multivendor_restaurant/controller/order_controller.dart';
import 'package:efood_multivendor_restaurant/data/model/response/order_model.dart';
import 'package:efood_multivendor_restaurant/helper/price_converter.dart';
import 'package:efood_multivendor_restaurant/helper/route_helper.dart';
import 'package:efood_multivendor_restaurant/util/dimensions.dart';
import 'package:efood_multivendor_restaurant/util/images.dart';
import 'package:efood_multivendor_restaurant/util/styles.dart';
import 'package:efood_multivendor_restaurant/view/base/confirmation_dialog.dart';
import 'package:efood_multivendor_restaurant/view/base/order_shimmer.dart';
import 'package:efood_multivendor_restaurant/view/base/order_widget.dart';
import 'package:efood_multivendor_restaurant/view/screens/home/widget/order_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:intl/intl.dart';

import '../../base/custom_snackbar.dart';

class HomeScreen extends StatefulWidget {

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _loadData() async {
    await Get.find<AuthController>().getProfile();
    await Get.find<OrderController>().getCurrentOrders();
    await Get.find<NotificationController>().getNotificationList();
  }

  DateTime fromDate;

  DateTime toDate;

  TimeOfDay fromTime;

  TimeOfDay toTime;

  Future<void> _selectTime(BuildContext context, bool isFromTime) async {
    TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: ThemeData.light().copyWith(
              primaryColor: Colors.green, // Change the primary color as needed
              accentColor: Colors.green, // Change the accent color as needed
              colorScheme: ColorScheme.light(primary: Colors.green),
              buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
            child: child,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFromTime) {
          fromTime = picked;
        } else {
          toTime = picked;
        }
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate:
        isFromDate ? fromDate ?? DateTime.now() : toDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: Theme.of(context)
                  .primaryColor, // Change the primary color as needed
              accentColor: Theme.of(context)
                  .primaryColor, // Change the accent color as needed
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).primaryColor,
              ),
              buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
            child: child,
          );
        });

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _loadData();

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        leading: Padding(
          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
          child: Image.asset(Images.logo, height: 60, width: 60,fit: BoxFit.cover,),
        ),
        titleSpacing: 0, elevation: 0,
        leadingWidth: 90,toolbarHeight: 90,
        /*title: Text(AppConstants.APP_NAME, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoMedium.copyWith(
          color: Theme.of(context).textTheme.bodyText1.color, fontSize: Dimensions.FONT_SIZE_DEFAULT,
        )),*/
        // title: Image.asset(Images.logo_name, width: 120),
        actions: [IconButton(
          icon: GetBuilder<NotificationController>(builder: (notificationController) {
            bool _hasNewNotification = false;
            if(notificationController.notificationList != null) {
              _hasNewNotification = notificationController.notificationList.length
                  != notificationController.getSeenNotificationCount();
            }
            return Stack(children: [
              Icon(Icons.notifications, size: 25, color: Theme.of(context).textTheme.bodyText1.color),
              _hasNewNotification ? Positioned(top: 0, right: 0, child: Container(
                height: 10, width: 10, decoration: BoxDecoration(
                color: Theme.of(context).primaryColor, shape: BoxShape.circle,
                border: Border.all(width: 1, color: Theme.of(context).cardColor),
              ),
              )) : SizedBox(),
            ]);
          }),
          onPressed: () => Get.toNamed(RouteHelper.getNotificationRoute()),
        )],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await _loadData();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(children: [

            GetBuilder<AuthController>(builder: (authController) {
              return Column(children: [
                ExpansionTile(
                  title: Text('Search Options'), // Change the title as needed
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("من",
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontFamily: 'Roboto',
                                      )),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () => _selectDate(context, true),
                                    child: Text(
                                      "${fromDate != null ? DateFormat("yyyy-MM-dd").format(fromDate) : "From Date"}",
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          fontFamily: 'Roboto',
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "الي",
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        _selectDate(context, false),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6),
                                      child: Text(
                                          " ${toDate != null ? DateFormat("yyyy-MM-dd").format(toDate) : "To Date"}",
                                          style: TextStyle(
                                              fontSize: 12.0,
                                              fontFamily: 'Roboto',
                                              color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("سعت",
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontFamily: 'Roboto',
                                      )),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () => _selectTime(context, true),
                                    child: Text(
                                      "${fromTime != null ? fromTime.format(context) : "From Time"}",
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          fontFamily: 'Roboto',
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "سعت",
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        _selectTime(context, false),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6),
                                      child: Text(
                                          "${toTime != null ? toTime.format(context) : "To Time"}",
                                          style: TextStyle(
                                              fontSize: 12.0,
                                              fontFamily: 'Roboto',
                                              color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        authController.isLoadingSearchData
                            ? Center(child: CircularProgressIndicator())
                            : Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              if (fromDate == null || toDate == null) {
                                showCustomSnackBar(
                                    'من فضلك ادخل تواريخ البحث اولاً');
                              } else if (fromTime == null ||
                                  toTime == null) {
                                showCustomSnackBar(
                                    'من فضلك ادخل توقيتات البحث اولاً');
                              } else {
                                authController.netBySearch(
                                    time:
                                    "?from_date=${"${fromDate.year ?? ""}-${fromDate.month ?? ""}-${fromDate.day ?? ""}"} ${"${fromTime.hour ?? ""}:${fromTime.minute ?? ""}"}"
                                        "&to_date=${"${toDate.year ?? ""}-${toDate.month ?? ""}-${toDate.day ?? ""}"} "
                                        "${"${toTime.hour ?? ""}:${toTime.minute ?? ""}"}");
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Theme.of(context).primaryColor),
                              child: Center(
                                  child: Icon(Icons.send,
                                      color: Colors.white)),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    color: Theme.of(context).cardColor,
                    boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 200], spreadRadius: 1, blurRadius: 5)],
                  ),
                  child: Row(children: [
                    Expanded(child: Text(
                      'restaurant_temporarily_closed'.tr, style: robotoMedium,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    )),
                    authController.profileModel != null ? Switch(
                      value: !authController.profileModel.restaurants[0].active,
                      activeColor: Theme.of(context).primaryColor,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (bool isActive) {
                        Get.dialog(ConfirmationDialog(
                          icon: Images.warning,
                          description: isActive ? 'are_you_sure_to_close_restaurant'.tr : 'are_you_sure_to_open_restaurant'.tr,
                          onYesPressed: () {
                            Get.back();
                            authController.toggleRestaurantClosedStatus();
                          },
                        ));
                      },
                    ) : Shimmer(duration: Duration(seconds: 2), child: Container(height: 30, width: 50, color: Colors.grey[300])),
                  ]),
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                Container(
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Image.asset(Images.wallet, width: 60, height: 60),
                      SizedBox(width: Dimensions.PADDING_SIZE_LARGE),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          'today'.tr,
                          style: robotoMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Theme.of(context).cardColor),
                        ),
                        SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                        Text(
                          authController.profileModel != null ? PriceConverter.convertPrice(authController.profileModel.todaysEarning) : '0',
                          style: robotoBold.copyWith(fontSize: 24, color: Theme.of(context).cardColor),
                        ),
                      ]),
                    ]),
                    SizedBox(height: 30),
                    Row(children: [
                      Expanded(child: Column(children: [
                        Text(
                          'this_week'.tr,
                          style: robotoMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Theme.of(context).cardColor),
                        ),
                        SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                        Text(
                          authController.profileModel != null ? PriceConverter.convertPrice(authController.profileModel.thisWeekEarning) : '0',
                          style: robotoMedium.copyWith(fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE, color: Theme.of(context).cardColor),
                        ),
                      ])),
                      Container(height: 30, width: 1, color: Theme.of(context).cardColor),
                      Expanded(child: Column(children: [
                        Text(
                          'this_month'.tr,
                          style: robotoMedium.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Theme.of(context).cardColor),
                        ),
                        SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                        Text(
                          authController.profileModel != null ? PriceConverter.convertPrice(authController.profileModel.thisMonthEarning) : '0',
                          style: robotoMedium.copyWith(fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE, color: Theme.of(context).cardColor),
                        ),
                      ])),
                      Container(
                          height: 30,
                          width: 1,
                          color: Theme.of(context).cardColor),
                      Expanded(
                          child: Column(children: [
                            Text(
                              'by_search'.tr,
                              style: robotoMedium.copyWith(
                                  fontSize: Dimensions.FONT_SIZE_SMALL,
                                  color: Theme.of(context).cardColor),
                            ),
                            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                            Text(
                              authController.net_by_searchData != null
                                  ? PriceConverter.convertPrice(double.tryParse(
                                  authController.net_by_searchData.isEmpty
                                      ? "0"
                                      : authController.net_by_searchData))
                                  : '0',
                              style: robotoMedium.copyWith(
                                  fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                                  color: Theme.of(context).cardColor),
                            ),
                          ])),
                    ]),
                  ]),
                ),
              ]);
            }),
            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

            GetBuilder<OrderController>(builder: (orderController) {
              List<OrderModel> _orderList = [];
              if(orderController.runningOrders != null) {
                _orderList = orderController.runningOrders[orderController.orderIndex].orderList;
              }

              return Column(children: [

                orderController.runningOrders != null ? Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).disabledColor, width: 1),
                    borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: orderController.runningOrders.length,
                    itemBuilder: (context, index) {
                      return OrderButton(
                        title: orderController.runningOrders[index].status.tr, index: index,
                        orderController: orderController, fromHistory: false,
                      );
                    },
                  ),
                ) : SizedBox(),

                orderController.runningOrders != null ? InkWell(
                  onTap: () => orderController.toggleCampaignOnly(),
                  child: Row(children: [
                    Checkbox(
                      activeColor: Theme.of(context).primaryColor,
                      value: orderController.campaignOnly,
                      onChanged: (isActive) => orderController.toggleCampaignOnly(),
                    ),
                    Text(
                      'campaign_order'.tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL, color: Theme.of(context).disabledColor),
                    ),
                  ]),
                ) : SizedBox(),

                orderController.runningOrders != null ? _orderList.length > 0 ? ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _orderList.length,
                  itemBuilder: (context, index) {
                    return OrderWidget(orderModel: _orderList[index], hasDivider: index != _orderList.length-1, isRunning: true);
                  },
                ) : Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(child: Text('no_order_found'.tr)),
                ) : ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return OrderShimmer(isEnabled: orderController.runningOrders == null);
                  },
                ),

              ]);
            }),

          ]),
        ),
      ),

    );
  }
}
