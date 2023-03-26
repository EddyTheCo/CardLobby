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
    required property User_box player;
    required property Players_model playersmodel;
    required property MyPayPopUp paypopup;
    required property BoutPublisher publisher;
    backColor:"#1e1e1e"
    description: qsTr("Oponent details")
    visible:(opponent!=null)


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
            text:(root_.opponent.jsob.duel)?qsTr("Accept duel"):qsTr("Let's duel")
            onClicked:{
                root_.playersmodel.opponentid=root_.opponent.jsob.id;
                if(root_.opponent.jsob.duel)
                {
                    var objson1={
                        "message": "You have no chance"
                    };
                    publisher.publish(objson1,root_.opponent.addr,"duelaccepted",[0,0,0],-1000);
                }
                else
                {

                    var outid=root_.opponent.jsob.id;
                    var objson2={
                        "cards": root_.player.nftmodel.gameCards.getCardIds(),
                        "username":root_.player.player.username,
                        "outid": outid
                    };
                    if(root_.player.player.nftbox)
                    {
                        objson2.profpic=root_.player.player.nftbox;
                    }

                    publisher.publish(objson2,root_.opponent.addr,"letsduel",[0,0,0],-1000);

                }
                scards.enabled=false;

            }
        }

    }

}


