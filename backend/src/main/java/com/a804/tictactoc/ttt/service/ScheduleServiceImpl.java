package com.a804.tictactoc.ttt.service;

import com.a804.tictactoc.ttt.common.CommonEnum;
import com.a804.tictactoc.ttt.common.CommonResult;
import com.a804.tictactoc.ttt.db.entity.*;
import com.a804.tictactoc.ttt.db.repository.*;
import com.a804.tictactoc.ttt.request.PushReq;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.transaction.Transactional;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ScheduleServiceImpl implements ScheduleService {

    @Autowired
    ConfigRepo configRepo;

    @Autowired
    HabitRepo habitRepo;

    @Autowired
    UserRepository userRepo;

    @Autowired
    PushService pushService;


    @Override
    @Transactional
    public CommonResult SendPushAlarm() {

        CommonResult result = new CommonResult();

        try{

            Config config = configRepo.findByName(CommonEnum.Config.push_alarm.name());

            // 알람 보내는 기능 켜져있는지
            if(config.getValue() == 1){
                LocalDateTime now = LocalDateTime.now();
                // 요일
                int yoil = now.getDayOfWeek().getValue();
                if(yoil == 7)
                    yoil = 0;

                String targetTime = String.format("%02d%02d",now.getHour(), now.getMinute());
                int finalYoil = yoil;

                List<Habit> resq = habitRepo.findAll().stream()
                        .filter(habit -> habit.getRepeatDay().substring(finalYoil,finalYoil + 1).equals("1")    // 울리는 요일 맞는지
                                        && habit.getDeleteYn() == 0                                     // 삭제 안되었는지
                                        && habit.getAlarms().stream().anyMatch(alarm -> alarm.getAlarmTime().equals(targetTime))    // 지금이 알람 울릴 시간인지
                                        && Integer.parseInt(habit.getStartTime()) <= Integer.parseInt(targetTime)   // 시작일 내인지
                                        && Integer.parseInt(habit.getEndTime()) >= Integer.parseInt(targetTime)     // 종료일 내인지
                                        && ((Integer.parseInt(habit.getUser().getSleepStartTime()) == Integer.parseInt(habit.getUser().getSleepEndTime()))
                                        ||
                                        (Integer.parseInt(habit.getUser().getSleepStartTime()) > Integer.parseInt(habit.getUser().getSleepEndTime())//밤~아침같은 시간대
                                                && Integer.parseInt(habit.getUser().getSleepStartTime()) > Integer.parseInt(targetTime)
                                                && Integer.parseInt(habit.getUser().getSleepEndTime()) < Integer.parseInt(targetTime))
                                        ||
                                        (Integer.parseInt(habit.getUser().getSleepStartTime()) < Integer.parseInt(habit.getUser().getSleepEndTime())//아침~오후같은 시간대
                                                && (Integer.parseInt(habit.getUser().getSleepStartTime()) > Integer.parseInt(targetTime)
                                                || Integer.parseInt(habit.getUser().getSleepEndTime()) < Integer.parseInt(targetTime)))
                                )
                        )
                        .collect(Collectors.toList());


                List<PushReq> pushList = new ArrayList<>();
                now = LocalDateTime.now();
                System.out.println("[" + now.toString() + "]" + resq.stream().count() + "개를 전송해야한다.");

                int successCount = 0;
                int failCount = 0;

                for (Habit habit:resq) {

                    pushList.add(new PushReq(habit.getName(),habit.getEmoji(), habit.getUser().getId()));
//                    System.out.println(pushList.get(i++).getEmoji());
                    // 유저 정보 : 현재는 하나하나 가져오게 되어있는데 추후에 한번에 가져와서 찾는 방식으로 개편 필요하다
                    User selectedUser = userRepo.findById(habit.getUser().getId()).get();

                    if(selectedUser != null
                            && selectedUser.getUid() != null
                            && selectedUser.getPhoneDeviceToken() != null){
                        if(pushService.SendPush(habit.getEmoji(),
                                habit.getName() + "할 시간입니다.",
                                selectedUser.getPhoneDeviceToken()
                                ,CommonEnum.PushType.PHONE
                                ,selectedUser.getId()
                                ,selectedUser.getUid())){
                            if(selectedUser.getWatchDeviceToken() != null){
                                //실패
                                if(pushService.SendPush(habit.getEmoji(),habit.getName() + "할 시간입니다."
                                        ,selectedUser.getWatchDeviceToken()
                                        ,CommonEnum.PushType.WATCH
                                        ,selectedUser.getId()
                                        ,selectedUser.getUid())){
                                    successCount++;
                                }
                                else{
                                    failCount++;
                                }
                            }
                            successCount++;
                        }
                        else{
                            failCount++;
                        }

                    }
                }
                result = new CommonResult(CommonEnum.Result.SUCCESS, successCount + "개의 메세지 전송에 성공했습니다.");
                now = LocalDateTime.now();
                System.out.println("[" + now.toString() + "]" + successCount + "개의 메세지 전송에 성공/" + failCount + "개의 매세지 전송에 실패 했습니다.");

            }
        }
        catch (Exception ex){
            System.out.println(ex);
            result = new CommonResult(CommonEnum.Result.FAIL, "메세지 전송에 실패했습니다.");
        }

        return result;
    }



}

