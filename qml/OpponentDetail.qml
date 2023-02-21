import QtQuick.Layouts
import QtQuick.Controls
import QtQuick
import MyDesigns
import nft_model
import userSettings


import bout_publisher
import players_model


MyFrame
{
    id:root_
    required property User_box opponent;
    required property NFT_model umodel;
    required property UserSetts usett;

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
        anchors.fill: root_;
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
            Layout.maximumHeight: 400
            Layout.minimumHeight: 200
            Layout.minimumWidth:300
            orientation:ListView.Horizontal
            Layout.alignment: Qt.AlignHCenter

            flickableDirection:Flickable.HorizontalFlick

            model: root_.opponent.nftmodel.gameCards
            delegate: SCardDelegate {
                width:100
                height:150
            }
        }
        MyButton
        {
            id:scards
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: 250
            Layout.maximumHeight: 100
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
                publisher.publish(objson,opponent.monitor.addr(),"Let's duel",-1000,true);

            }
        }

    }


    ListView {
        id:playersview
        Layout.fillWidth: true
        Layout.fillHeight: true

        Layout.preferredWidth: 360
        Layout.maximumWidth: 360
        orientation:ListView.Vertical
        Layout.alignment: Qt.AlignRight

        flickableDirection:Flickable.VerticalFlick

        model: playersmodel
        delegate: PlayersDelegate {
            width:playersview.width
            height:playersview.height/4.0
        }
    }


}


