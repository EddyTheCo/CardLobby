import QtQuick.Layouts
import QtQuick.Controls
import QtQuick
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
    backColor:"#1e1e1e"
    description: qsTr("Oponent details")

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
        connection: Node_Conection
        onReady:
        {
            fundsmonitor.addr=Account.addr([0,0,0]);
        }
        onGotNewBout:
        {
            paypopup.visible=false;
        }
    }
    BoutPublisher
    {
        id:publisher
        connection: Node_Conection
        account: Account
        onNotenoughFunds: function (amount) {
            paypopup.addr_=Account.addr([0,0,0]);
            paypopup.descr_=qsTr("Transfer at least "+ amount + " to \n" +paypopup.addr_);
            paypopup.visible=true;
            fundsmonitor.eventMonitor();
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
            text:qsTr("Let's duel")
            onClicked:{

                var objson={
                    "cards": root_.umodel.gameCards.getCardIds(),
                    "username":root_.usett.username
                };
                if(root_.usett.nftbox)
                {
                    objson.profpic=root_.usett.nftbox.nftid;
                }
                publisher.publish(objson,root_.opponent.monitor.addr,"Let's duel",[0,0,0],-1000);

            }
        }

    }

}


