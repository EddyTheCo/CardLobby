import QtQuick.Layouts
import QtQuick.Controls
import QtQuick
import MyDesigns
import nft_model
import userSettings
import account
import bout_monitor
import bout_publisher
import players_model
import nodeConection

MyFrame
{
    id:root_
    required property User_box ubox;

    description: qsTr("Game Lobby")
    Connections {
        target: Account

        function onSeedChanged() {
            fundsmonitor.restart();
            fundsmonitor.addr=Account.addr([0, 0, 0]);
            fundsmonitor.addressMonitor();
            playersmodel.restart();
        }
    }
    Connections {
        target: Node_Conection
        function onStateChanged() {
            fundsmonitor.restart();
            playersmodel.restart();
        }
    }

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
        onGotNewBout:
        {
            paypopup.visible=false;
        }
    }

    BoutPublisher
    {
        id:publisher
        onNotenoughFunds: function (amount) {
            paypopup.addr_=Account.addr_bech32([0,0,0],Node_Conection.info().protocol.bech32Hrp);
            paypopup.descr_=qsTr("Transfer at least "+ amount + " "+ Node_Conection.info().baseToken.subunit + " to \n" +paypopup.addr_);
            paypopup.visible=true;
        }
    }
    Players_model
    {
        id:playersmodel
        onSelected: (box) => oponentdetail.opponent=box;

    }

    RowLayout
    {
        id:rowllay
        anchors.fill: parent
        spacing: 10
        ColumnLayout
        {
            id:left_

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 200
            Layout.minimumHeight: 100
            Layout.alignment: Qt.AlignLeft

            spacing:20
            OpponentDetail
            {
                id:oponentdetail
                player:root_.ubox
                opponent:null
                paypopup:paypopup
                publisher:publisher
                playersmodel:playersmodel
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 360
                Layout.minimumHeight: 300
                Layout.alignment: Qt.AlignTop
            }

            MyButton
            {
                id:scards
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumWidth: 250
                Layout.maximumHeight: 100
                Layout.alignment: Qt.AlignHCenter
                text:qsTr("I want to play")
                onClicked:{

                    var objson={
                        "cards": root_.ubox.nftmodel.gameCards.getCardIds(),
                        "username":root_.ubox.player.username
                    };
                    if(root_.ubox.player.nftbox)
                    {
                        objson.profpic=root_.ubox.player.nftbox.nftid;
                    }

                    publisher.publish(objson,Account.addr([0,0,0]),"iwantoplaycards",[0,0,0],-10000);
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

}
