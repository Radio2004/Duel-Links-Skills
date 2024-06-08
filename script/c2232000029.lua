--Borreload Link
local s,id=GetID()
function s.initial_effect(c)
	--Activate Skill
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SUMMON_PROC)
		e1:SetTargetRange(LOCATION_HAND,0)
		e1:SetCondition(s.ntcon)
		e1:SetTarget(aux.FieldSummonProcTg(s.nttg))
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_PROC)
		Duel.RegisterEffect(e2,tp)
		--spsummon limit
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetTargetRange(1,0)
		e3:SetTarget(s.splimit)
		Duel.RegisterEffect(e3,tp)
		local e4=e3:Clone(e3)
		e4:SetCode(EFFECT_CANNOT_SUMMON)
		Duel.RegisterEffect(e4,tp)
	end
	e:SetLabel(1)
end

function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end

function s.nttg(e,c)
	return c:IsLevelAbove(5) and c:GetDefense()+c:GetAttack()==4000
end

function s.filter(c,e,tp)
	return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLink(2) and c:IsSetCard(0x10f)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_CYBERSE+RACE_DRAGON))
end

function s.revealtfilter(c)
	return c:IsLevelAbove(7) and c:IsRace(RACE_DRAGON) and c:IsMonster() and not c:IsPublic()
end

function s.filter(c)
	return c:IsLevelAbove(7) and c:IsRace(RACE_DRAGON) and c:IsMonster() and c:IsAbleToGrave()
end

function s.thfilter(c)
	return c:IsMonster() and c:IsAbleToHand() and c:GetAttack()+c:GetDefense()==4000
end


function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--OPT check
	if Duel.GetFlagEffect(tp,id)>0 and Duel.GetFlagEffect(tp,id+1)>0 then return end

	--Boolean checks for the activation condition: b1, b2
	local b1=Duel.GetFlagEffect(tp,id)==0 and  Duel.IsExistingMatchingCard(s.revealtfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK|LOCATION_HAND,0,2,nil) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		

	local b2=Duel.GetFlagEffect(tp,id+1)==0 and Duel.IsExistingMatchingCard(Card.IsMonster,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,nil)


	return aux.CanActivateSkill(tp) and (b1 or b2)
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Boolean check for effect 1:
	local b1=Duel.GetFlagEffect(tp,id)==0 and  Duel.IsExistingMatchingCard(s.revealtfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK|LOCATION_HAND,0,2,nil) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)

	local b2=Duel.GetFlagEffect(tp,id+1)==0 and Duel.IsExistingMatchingCard(Card.IsMonster,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,nil)

	local op=Duel.SelectEffect(tp, {b1,aux.Stringid(id,0)},
								   {b2,aux.Stringid(id,1)})
	op=op-1 --SelectEffect returns indexes starting at 1, so we decrease the result by 1 to match your "if"s

	if op==0 then
		s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	end
end

function s.operation_for_res0(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local reveal=Duel.SelectMatchingCard(tp,s.revealtfilter,tp,LOCATION_HAND,0,1,1,nil)
	if #reveal>0 then
		Duel.ConfirmCards(1-tp,reveal)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK|LOCATION_HAND,0,2,2,nil)
		if #g>1 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.operation_for_res1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.RegisterFlagEffect(tp,id+1,0,0,0)
end