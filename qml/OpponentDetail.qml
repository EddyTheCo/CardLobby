import QtQuick.Layouts
import QtQuick.Controls
import QtQuick 2.0
import MyDesigns
import nft_model
import userSettings
import card_designs

import bout_publisher
import players_model


MyFrame
{
    id:root_
    required property User_box opponent;
    required property NFT_model umodel;
    required property UserSetts usett;
    required property Players_model playersmodel
    backColor:"#1e1e1e"
    description: qsTr("Oponent details")
    visible:(opponent!=null)
    MyPayPopUp
    {
        id:paypopup
        addr_:""
        descr_:""
        visible:false
        closePolicy: Popup.CloseOnPressOutside
        anchors.centerIn: Overlay.overlay
    }
    BoutMonitor{
        id:fundsmonitor
        addr:Account.addr([0,0,0]);
        Component.onCompleted:
        {
            fundsmonitor.addressMonitor();
        }
        onGotNewBout:
        {
            paypopup.visible=false;
        }
    }

    BoutPublisher
    {
        id:publisher
        onNotenoughFunds: function (amount) {
            paypopup.addr_=Account.addr_bech32([0,0,0]);
            paypopup.descr_=qsTr("Transfer at least "+ amount + " to \n" +paypopup.addr_);
            paypopup.visible=true;
        }
    }

    ColumnLayout
    {
        id:opponentbox
        anchors.fill: parent;
        spacing:10

        UserDelegate
        {
            user_sets_:root_.opponent.player
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: 350
            Layout.maximumHeight: 350
            Layout.alignment: Qt.AlignHCenter
        }
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: 600
            Layout.minimumHeight: 450
            Layout.minimumWidth:300
            orientation:ListView.Horizontal
            Layout.alignment: Qt.AlignHCenter
            clip:true
            flickableDirection:Flickable.HorizontalFlick

            model: root_.opponent.nftmodel.gameCards
            delegate: SCardDelegate {
                width:300
                height:450
            }
        }

        MyButton
        {
            id:scards
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: 150
            Layout.maximumHeight: 75
            Layout.alignment: Qt.AlignHCenter
            text:(root_.opponent.isduel)?qsTr("Accept duel"):qsTr("Let's duel")
            onClicked:{
                root_.playersmodel.opponentid=root_.opponent.id();
                if(root_.opponent.isduel)
                {
                    var objson1={
                        "message": "You have no chance"
                    };
                    publisher.publish(objson1,root_.opponent.monitor.addr,"duelaccepted",[0,0,0],-1000);
                }
                else
                {

                    var outid=root_.opponent.id();
                    var objson2={
                        "cards": root_.umodel.gameCards.getCardIds(),
                        "username":root_.usett.username,
                        "outid": outid
                    };
                    if(root_.usett.nftbox)
                    {
                        objson2.profpic=root_.usett.nftbox.nftid;
                    }

                    publisher.publish(objson2,root_.opponent.monitor.addr,"letsduel",[0,0,0],-1000);

                }
                scards.enabled=false;

            }
        }

    }

}


