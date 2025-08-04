  <div class="content" >
    <div class="flex " >
        <div class="col" style="max-width: 100%;margin: 0px auto;">
            <div class="flex no_padding wrap">
                <div class="col">
                    <div class="flex no_padding wrap">
                        <div class="col-lg-3">
                            <div class="content-area " style="min-height: 10px;">
                                <button class="btn-dep w-100" onclick="load('admin/settings_site');">Настройки сайта</button>
                            </div>
                        </div>

                        <div class="col-lg-3">
                            <div class="content-area " style="min-height: 10px;" >
                                <button class="btn-dep w-100" onclick="load('admin/settings_withdraw');">Настройки вывода</button>
                            </div>
                        </div>

                        <div class="col-lg-3">
                            <div class="content-area " style="min-height: 10px;">
                                <button class="btn-dep w-100" onclick="load('admin/settings_deps');">Настройки пополнения</button>
                            </div>
                        </div>

                        <div class="col-lg-3">
                            <div class="content-area " style="min-height: 10px;">
                                <button class="btn-dep w-100" onclick="load('admin/settings_bonus');">Настройки бонуса</button>
                            </div>
                        </div>

                        

                        <div class="col-lg-3">
                            <div class="content-area " style="min-height: 10px;">
                                <button class="btn-dep w-100" onclick="load('admin/settings_random');">Настройки  Random.Org</button>
                            </div>
                        </div>

                        <div class="col-lg-3">
                            <div class="content-area " style="min-height: 10px;">
                                <button class="btn-dep w-100" onclick="load('admin/settings_partner');">Настройки сотрудничества</button>
                            </div>
                        </div>

                        <div class="col-lg-3">
                            <div class="content-area " style="min-height: 10px;">
                                <button class="btn-dep w-100" onclick="load('admin/settings_anti');">Настройки антиминуса</button>
                            </div>
                        </div>

                        <div class="col-lg-3">
                            <div class="content-area " style="min-height: 10px;">
                                <button class="btn-dep w-100" onclick="load('admin/settings_status');">Настройки привилегий</button>
                            </div>
                        </div>

                        <div class="col-lg-3">
                            <div class="content-area " style="min-height: 10px;">
                                <button class="btn-auth w-100" onclick="load('admin/settings_repost');">Настройки репоста</button>
                            </div>
                        </div>
                    </div>
                    @php
                    $setting = \App\Setting::first();
                    @endphp
                    <div class="flex no_padding wrap">
                        <div class="col-lg-5">
                            <div class="flex no_padding wrap" id="all_repost">

                            </div>
                            
                        </div>
                        <div class="col-lg-5">
                            <div class="content-area">
                                <span class="text-secondary" id="title_s_w">Добавление уровня репоста</span>
                                <div class="flex no_padding wrap" style="margin-top: 20px;">
                                    <div class="col mb-20">
                                        <label>Цвет</label>
                                        <div class="flex no_padding wrap">
                                            <div style="position:relative;margin-top: 10px;" class="col">
                                                <input type="color"  class="secodary_input" id="color_repost" name="">
                                            </div>
                                        </div>
                                    </div>

                                    <input type="hidden" id="id_repost"  name="">

                                   <!--  <div class="col-5 mb-20">
                                        <label>Репостов от</label>
                                        <div class="flex no_padding wrap">
                                            <div style="position:relative;margin-top: 10px;" class="col">
                                                <input type="" class="secodary_input" id="from_repost" value="50" name="">
                                            </div>
                                        </div>   
                                    </div> -->

                                    <div class="col-5 mb-20">
                                        <label>Репостов до</label>
                                        <div class="flex no_padding wrap">
                                            <div style="position:relative;margin-top: 10px;" class="col">
                                                <input type="" class="secodary_input" id="to_repost" value="50" name="">
                                            </div>
                                        </div>   
                                    </div>

                                    

                                    <div class="col mb-20">
                                        <label>Бонус</label>
                                        <div class="flex no_padding wrap">
                                            <div style="position:relative;margin-top: 10px;" class="col">
                                                <input type="" class="secodary_input" id="bonus_repost" value="" name="">
                                            </div>
                                        </div>   
                                    </div>




                                    
                                    <div class="col mb-20 buttons_s_w_1">
                                        <button class="btn-auth w-100" onclick="addRepost()">Добавить</button>
                                    </div>
                                    
                                    <div class="col-lg-5 mb-20 buttons_s_w_2" style="display: none;">
                                        <button class="btn-dep w-100" onclick="closeEditRepost()">Закрыть</button>
                                    </div>
                                    <div class="col-lg-5 mb-20 buttons_s_w_2" style="display: none;">
                                        <button class="btn-auth w-100" onclick="saveEditRepost()">Сохранить</button>
                                    </div>
                                    
                                    

                                </div>
                            </div>  
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    function getRepost() {
        $.post('/repost/all',{_token: csrf_token}).then(e=>{
            $('#all_repost').html('')
            e.repost.forEach((e)=>{

                $('#all_repost').append('<div class="col-lg-5">\
                    <div class="content-area no_padding" >\
                    <div class="header_color" style="background: '+e.color+'"></div>\
                    <div class="padding-20">\
                    <span class="text-secondary" style="font-size:16px;display:block">'+e.id+' уровень</span> <br>   \
                    <div class="flex no_padding">\
                    <div class="w-100"><span class="text-secondary" style="font-size:16px">Репостов до:</span>    \
                    <span class="text-secondary text-admin-title" style="color: black;font-size:35px;margin-top: 20px;margin-bottom: 30px;display: block;">'+e.repost_to+'</span> </div>\
                    <div class="w-100"><span class="text-secondary" style="font-size:16px">Бонус:</span>    \
                    <span class="text-secondary text-admin-title" style="color: black;font-size:35px;margin-top: 20px;margin-bottom: 30px;display: block;">'+e.bonus+'</span> </div>\
                    </div>\
                    \
                    <div class="flex no_padding wrap">\
                    <div class="col-5"><button class="btn-dep w-100" onclick="deleteRepost('+e.id+')">Удалить</button></div>\
                    <div class="col-5"><button class="btn-dep w-100" onclick="editRepost('+e.id+', `'+e.color+'`, `'+e.repost_to+'`, `'+e.bonus+'`)">Редактировать</button></div>\
                    </div>\
                    </div>\
                    </div>\
                    </div>')
            });
        });
    }
    getRepost()
</script>
